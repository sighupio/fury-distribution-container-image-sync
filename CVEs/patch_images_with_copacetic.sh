#!/bin/bash

source $(dirname $0)/utils.sh
source $(dirname $0)/logging.sh

IMAGE_TO_PATCH=
FILE_WITH_IMAGES_LIST_TO_PATCH=
PATCH_REPORT_OUTPUT_FILE=

function usage() {
    echo "Usage: $0 -i IMAGE_TO_PATCH | -l FILE_WITH_IMAGES_LIST_TO_PATCH [-o PATCH_REPORT_OUTPUT_FILE ]"
}

while getopts ":i:l:o:" o; do
    case "${o}" in
        i)
            IMAGE_TO_PATCH=${OPTARG}
            ;;
        l)
            FILE_WITH_IMAGES_LIST_TO_PATCH=${OPTARG}
            ;;
        o)
            PATCH_REPORT_OUTPUT_FILE=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

[[ -z ${FILE_WITH_IMAGES_LIST_TO_PATCH} ]] && FILE_WITH_IMAGES_LIST_TO_PATCH=images.txt
[[ -z ${PATCH_REPORT_OUTPUT_FILE} ]] && PATCH_REPORT_OUTPUT_FILE=PATCHED.md

DEFAULT_PATCH_REPORT_OUTPUT_FILE="${PATCH_REPORT_OUTPUT_FILE}"

TRIVY_SCAN_OUTPUT_DIR=.patching/scan
COPA_PATCH_OUTPUT_DIR=.patching/patch
DOCKERFILE_OUTPUT_DIR=.patching/dockerfile
LOG_OUTPUT_DIR=.patching/log
PATCH_ERROR_OUTPUT_FILE="${LOG_OUTPUT_DIR}/patch-error.log"

if [ -z "$(docker ps -f name=buildkitd -q 2> /dev/null)" ]
then
  info "Start buildkitd instance for COPA"
  if [ -n "${DOCKER_CONFIG}" ]
  then
    docker_config_extra_args="-v ${DOCKER_CONFIG}:/root/.docker"
  fi
  if ! docker run --detach --rm --privileged ${docker_config_extra_args} -p 127.0.0.1:8888:8888/tcp --name buildkitd --entrypoint buildkitd registry.sighup.io/fury-secured/moby/buildkit:v0.16.0 --addr tcp://0.0.0.0:8888 2> /dev/null # --platform linux/amd64
  then
    fail "can't start buildkit"
  fi
else
  info "buildkit is already running"
fi

mkdir -p "${TRIVY_SCAN_OUTPUT_DIR}" "${COPA_PATCH_OUTPUT_DIR}" "${DOCKERFILE_OUTPUT_DIR}" "${LOG_OUTPUT_DIR}"
echo -n "" > "${PATCH_ERROR_OUTPUT_FILE}"

REGISTRY_BASE_URL='registry.sighup.io/fury/'
REGISTRY_SECURED_BASE_URL='registry.sighup.io/fury-secured/'
RETURN_ERROR=0

function patch_image() {
  local image="$1"
  image_to_patch="${image}"
  image_to_patch_repo=$(echo ${image_to_patch} | cut -d: -f1)
  image_to_patch_tag=$(echo ${image_to_patch} | cut -d: -f2)

  secured_image=${image//"${REGISTRY_BASE_URL}"/"${REGISTRY_SECURED_BASE_URL}"}
  secured_image_repo=$(echo ${secured_image} | cut -d: -f1)

  ARCHITECTURES=$(get_architecture_and_digest ${image_to_patch} | jq -r '.[].architecture' )
  [[ -z "${ARCHITECTURES}" ]] && error "no architectures found for ${image_to_patch}" && RETURN_ERROR=$((RETURN_ERROR + 1 )) && return 1

  MULTI_ARCH_IMAGES=""

  for ARCHITECTURE in ${ARCHITECTURES[@]}
  do

    image_to_patch_with_digest="${image_to_patch_repo}@$(get_architecture_and_digest ${image_to_patch} | jq -r \
      --arg arch ${ARCHITECTURE} \
      '.[] | select(.architecture == $arch) | .digest ' \
    )"
    if ! docker pull "${image_to_patch_with_digest}" --platform linux/${ARCHITECTURE} > /dev/null 2>&1
    then
      error "Failed pull ${image_to_patch_with_digest} for linux/${ARCHITECTURE}"
      RETURN_ERROR=$((RETURN_ERROR + 1))
      continue
    fi
    # Replace with skopeo/podman if exists a command that get imageId
    image_to_patch_image_id=$(docker inspect "${image_to_patch_with_digest}" --format '{{.Id}}')
    docker rmi -f ${image_to_patch_with_digest} > /dev/null
    patched_tag="${image_to_patch_tag}-${ARCHITECTURE}-patched"
    # Handling image with no tag
    [ ${image_to_patch_tag} = ${image_to_patch} ] && patched_tag="latest-${ARCHITECTURE}-patched"
    secured_image_with_tag_arch="${secured_image}-${ARCHITECTURE}"

    TRIVY_SCAN_OUTPUT_FILE=${TRIVY_SCAN_OUTPUT_DIR}/${image_to_patch//[:\/]/_}-${ARCHITECTURE}.json
    COPA_REPORT_OUTPUT_FILE=${COPA_PATCH_OUTPUT_DIR}/${image_to_patch//[:\/]/_}-${ARCHITECTURE}.vex.json
    COPA_PATCHING_LOG_FILE=${COPA_PATCH_OUTPUT_DIR}/${image_to_patch//[:\/]/_}-${ARCHITECTURE}.log
    info "Looking for CVEs in ${image_to_patch} for linux/${ARCHITECTURE}"
    trivy image --platform=linux/${ARCHITECTURE} --skip-db-update --skip-java-db-update --scanners vuln -q --vuln-type os --ignore-unfixed -f json -o "${TRIVY_SCAN_OUTPUT_FILE}" "${image_to_patch_with_digest}"
    info "Clean trivy scan cache for ${image_to_patch_with_digest}"
    trivy clean --scan-cache
    info "Patching CVEs in ${image_to_patch} for linux/${ARCHITECTURE}"
    copa patch -r "${TRIVY_SCAN_OUTPUT_FILE}" -i "${image_to_patch_with_digest}" --tag ${patched_tag} --format="openvex" --output "$COPA_REPORT_OUTPUT_FILE" -a tcp://127.0.0.1:8888 2>&1 | tee "${COPA_PATCHING_LOG_FILE}"
    copa_exit_code=${PIPESTATUS[0]}

    if [ "${copa_exit_code}" -eq 0 ]
    then
      image_patched="${image_to_patch_repo}:${patched_tag}"
      PATCH_REPORT_OUTPUT_FILE="${DEFAULT_PATCH_REPORT_OUTPUT_FILE%.md}.${ARCHITECTURE}.md"
      {
        [[ -n ${IMAGE_TO_PATCH} ]] && printf "# %s\n\n" "${IMAGE_TO_PATCH}"
        printf "Last updated %s\n\n" "$(date +'%Y-%m-%d')";
        printf "## Arch %s\n\n" ${ARCHITECTURE};
        printf "## CVEs patched\n\n" ;
        echo "| Source Image | Arch | Source Image ID | CVE | Severity | Description | Patched Image| Patched Image ID |"
        echo "| --- | --- | --- | --- | --- |--- | --- | --- |"
      } > "${PATCH_REPORT_OUTPUT_FILE}"

      FIXED_CVES=$(jq '.statements[] | select(.status=="fixed") | .vulnerability."@id"' -r < "${COPA_REPORT_OUTPUT_FILE}" | sort -r )
      info "CVEs patched in ${ARCHITECTURE} ${image_patched}: ${FIXED_CVES//[$'\r\n']/ }"
      DOCKER_LABELS=
      image_patched_image_id=$(docker inspect "${image_patched}" --format '{{.Id}}')
      info "${ARCHITECTURE} ${image_patched} image id: ${image_patched_image_id}"
      info "Update patching report for ${ARCHITECTURE} ${image_to_patch}"
      for FIXED_CVE in ${FIXED_CVES[@]}
      do
        DOCKER_LABELS="--label io.sighup.secured.${FIXED_CVE}=fixed ${DOCKER_LABELS}"
        jq -r \
        --arg cve "${FIXED_CVE}" \
        --arg image_to_patch "${image_to_patch}" \
        --arg image_to_patch_image_id "${image_to_patch_image_id}" \
        --arg image_patched "${image_patched}" \
        --arg image_patched_image_id "${image_patched_image_id}" \
        --arg arch ${ARCHITECTURE} \
        '[try .Results[].Vulnerabilities[] | select(.VulnerabilityID==$cve)][0] | "|" + $image_to_patch + " | " + $arch + " | " + $image_to_patch_image_id + " | " + .VulnerabilityID + " | " +  .Severity +  " | " + .Title + " | " + $image_patched + "|" + $image_patched_image_id + "|"' < "$TRIVY_SCAN_OUTPUT_FILE">> "$PATCH_REPORT_OUTPUT_FILE"
      done
      info "Tag ${image_patched} as secured image: ${secured_image_with_tag_arch}"
      echo "FROM ${image_patched}" | DOCKER_BUILDKIT=0 docker build \
        ${DOCKER_LABELS} \
        --label io.sighup.secured.image.arch="${ARCHITECTURE}" \
        --label io.sighup.secured.image.created="$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")" \
        --label io.sighup.secured.image.from.imageId="${image_to_patch_image_id}" \
        -t "${secured_image_with_tag_arch}" \
        -f - "${DOCKERFILE_OUTPUT_DIR}" &> /dev/null
      secured_image_labeled_image_id=$(docker inspect "${secured_image_with_tag_arch}" --format '{{.Id}}')
      if [ ${DRY_RUN:-1} -eq 0 ]
      then
        info "Push secure image: ${secured_image_with_tag_arch}"
        docker push $(docker inspect ${secured_image_with_tag_arch} --format '{{json .RepoDigests}}' | jq '.[0]' -r)
        MULTI_ARCH_IMAGES="${secured_image_with_tag_arch} ${MULTI_ARCH_IMAGES}"
      fi
      sed -i'.unsecured' s#"${image_patched}"#"${secured_image}"# "${PATCH_REPORT_OUTPUT_FILE}"
      sed -i'.unsecured' s#"${image_patched_hashimage_patched_image_id}"#"${secured_image_labeled_image_id}"# "${PATCH_REPORT_OUTPUT_FILE}"
      rm "${PATCH_REPORT_OUTPUT_FILE}.unsecured"
      info "Cleanup ${image_patched}"
      buildctl --addr tcp://127.0.0.1:8888 prune
      docker rmi -f "${image_patched}"
      info "cleanup ${secured_image_with_tag_arch}"
      docker rmi -f "${secured_image_with_tag_arch}"
      success "${secured_image_with_tag_arch} pushed with image id: ${secured_image_labeled_image_id}"
    else
      if [ "${image_to_patch}" != "${secured_image}" ]
      then
        copa_error="$(awk -F'Error: ' '$0 ~ /Error:/ {print $2}' ${COPA_PATCHING_LOG_FILE})"
        echo "linux/${ARCHITECTURE} ${secured_image}: ${copa_error}" >> "${PATCH_ERROR_OUTPUT_FILE}"
        error "${copa_error} patching ${image_to_patch} for linux/${ARCHITECTURE}"
        if [ ${DRY_RUN:-1} -eq 0 ]
        then
          warn "As fallback tag ${image_to_patch_with_digest} as secured image: ${secured_image_with_tag_arch}"
          skopeo_run "skopeo copy \
            --authfile=\$DOCKER_CONFIG/config.json \
            docker://${image_to_patch_with_digest} \
            docker://${image_to_patch_with_digest//${REGISTRY_BASE_URL}/${REGISTRY_SECURED_BASE_URL}}"
          MULTI_ARCH_IMAGES="${image_to_patch_with_digest//${REGISTRY_BASE_URL}/${REGISTRY_SECURED_BASE_URL}} ${MULTI_ARCH_IMAGES}"
          success "${secured_image_with_tag_arch} pushed with image id: ${image_to_patch_image_id}"
        fi
      else
        warn "${image_to_patch} is the same of ${secured_image}"
      fi
    fi
  done

  if [ ${DRY_RUN:-1} -eq 0 ] && [[ -n ${MULTI_ARCH_IMAGES} ]]
  then
    info "Create and push manifest ${secured_image}"
    podman_run "podman manifest create ${secured_image} ${MULTI_ARCH_IMAGES} && podman manifest push ${secured_image}"
    success "manifest ${secured_image} pushed"
  fi

  echo "================================================================"
  echo ""
  return 0
}

function patch_from_list(){
  while IFS= read -r image; do
    patch_image "${image}"
  done
}

if [ -n "${IMAGE_TO_PATCH}" ]
then
  patch_image "${IMAGE_TO_PATCH}"
else
  [[ ! -f "${FILE_WITH_IMAGES_LIST_TO_PATCH}" ]] && fail "Missing image list files"
  patch_from_list < "${FILE_WITH_IMAGES_LIST_TO_PATCH}"
fi

exit $RETURN_ERROR