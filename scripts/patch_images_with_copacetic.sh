#!/bin/bash

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

[[ -z $FILE_WITH_IMAGES_LIST_TO_PATCH ]] && FILE_WITH_IMAGES_LIST_TO_PATCH=images.txt
[[ -z $PATCH_REPORT_OUTPUT_FILE ]] && PATCH_REPORT_OUTPUT_FILE=PATCHED.md

TRIVY_SCAN_OUTPUT_DIR=.patching/scan
COPA_PATCH_OUTPUT_DIR=.patching/patch
DOCKERFILE_OUTPUT_DIR=.patching/dockerfile
LOG_OUTPUT_DIR=.patching/log
PATCH_ERROR_OUTPUT_FILE="$LOG_OUTPUT_DIR/patch-error.log"

if [ -z "$(docker ps -f name=buildkitd -q)" ]
then
  echo ">>>>>>>>>>>>>>>>>>> Start buildkitd instance for COPA <<<<<<<<<<<<<<<<<<<<<"
  if [ -n "$DOCKER_CONFIG" ]
  then
    docker_config_extra_args="-v ${DOCKER_CONFIG}:/root/.docker"
  fi
  docker run --detach --rm --privileged $docker_config_extra_args -p 127.0.0.1:8888:8888/tcp --name buildkitd --entrypoint buildkitd moby/buildkit:v0.16.0 --addr tcp://0.0.0.0:8888 # --platform linux/amd64
fi

mkdir -p "$TRIVY_SCAN_OUTPUT_DIR" "$COPA_PATCH_OUTPUT_DIR" "$DOCKERFILE_OUTPUT_DIR" "$LOG_OUTPUT_DIR"
echo -n "" > "${PATCH_ERROR_OUTPUT_FILE}"

{
[[ -n $IMAGE_TO_PATCH ]] && printf "# %s\n\n" $IMAGE_TO_PATCH
printf "Last updated %s\n\n" "$(date +'%Y-%m-%d')";
printf "## CVEs patched\n\n" ;
echo "| Source Image | Source Image Hash |CVE | Severity | Description | Patched Image| Patched Image Hash |"
echo "| --- | --- | --- | --- |--- | --- | --- |"
} > "${PATCH_REPORT_OUTPUT_FILE}"


REGISTRY_BASE_URL='registry.sighup.io/fury'
REGISTRY_SECURED_BASE_URL='registry.sighup.io/fury-secured'

function patch_image() {
  local image="$1"
  secured_image=${image//"${REGISTRY_BASE_URL}"/"${REGISTRY_SECURED_BASE_URL}"}
  image_to_patch="$image"

  DOCKER_PULL_OUTPUT_FILE="$LOG_OUTPUT_DIR/${image_to_patch//[:\/]/_}-image-pull.log"
  if ! docker pull "$image_to_patch" >> "${DOCKER_PULL_OUTPUT_FILE}" 2>&1
  then
    echo ">>>>>>>>>>>>>>>>>>> Failed pull $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
    cat "${DOCKER_PULL_OUTPUT_FILE}"
    return 1
  fi

  TRIVY_SCAN_OUTPUT_FILE=$TRIVY_SCAN_OUTPUT_DIR/${image_to_patch//[:\/]/_}.json
  COPA_REPORT_OUTPUT_FILE=$COPA_PATCH_OUTPUT_DIR/${image_to_patch//[:\/]/_}.vex.json
  COPA_PATCHING_LOG_FILE=$COPA_PATCH_OUTPUT_DIR/${image_to_patch//[:\/]/_}.log
  echo ">>>>>>>>>>>>>>>>>>> Scan $image_to_patch for CVEs <<<<<<<<<<<<<<<<<<<<<"
  trivy image --skip-db-update --skip-java-db-update --scanners vuln -q --vuln-type os --ignore-unfixed -f json -o "${TRIVY_SCAN_OUTPUT_FILE}" "$image_to_patch" # --platform=linux/amd64
  echo ">>>>>>>>>>>>>>>>>>> Clean trivy scan cache for $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
  trivy clean --scan-cache
  echo ">>>>>>>>>>>>>>>>>>> Patching CVEs for $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
  copa patch -r "${TRIVY_SCAN_OUTPUT_FILE}" -i "$image_to_patch" --format="openvex" --output "$COPA_REPORT_OUTPUT_FILE" -a tcp://127.0.0.1:8888 2>&1 | tee "$COPA_PATCHING_LOG_FILE"
  copa_exit_code=${PIPESTATUS[0]}

  if [ "$copa_exit_code" -eq 0 ]
  then
    FIXED_CVES=$(jq '.statements[] | select(.status=="fixed") | .vulnerability."@id"' -r < "$COPA_REPORT_OUTPUT_FILE" | sort -r)
    echo ">>>>>>>>>>>>>>>>>>> ${FIXED_CVES} patched in $image_to_patch-patched <<<<<<<<<<<<<<<<<<<<<"
    DOCKER_LABELS=
    image_patched_hash=$(docker inspect "$image_to_patch-patched" --format '{{.Id}}')
    echo ">>>>>>>>>>>>>>>>>>> $image_to_patch-patched hash: ${image_patched_hash} <<<<<<<<<<<<<<<<<<<<<"
    echo ">>>>>>>>>>>>>>>>>>> Update patching report for $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
    image_to_patch_hash=$(jq -r '.Metadata.ImageID' < "$TRIVY_SCAN_OUTPUT_FILE")
    for FIXED_CVE in ${FIXED_CVES[@]}
    do
      DOCKER_LABELS="--label io.sighup.secured.${FIXED_CVE}=fixed ${DOCKER_LABELS}"
      jq -r \
      --arg cve "$FIXED_CVE" \
      --arg image_to_patch "$image_to_patch" \
      --arg image_to_patch_hash "$image_to_patch_hash" \
      --arg image_patched "$image_to_patch-patched" \
      --arg image_patched_hash "$image_patched_hash" \
      '[try .Results[].Vulnerabilities[] | select(.VulnerabilityID==$cve)][0] | "|" + $image_to_patch + " | " + $image_to_patch_hash + " | " + .VulnerabilityID + " | " +  .Severity +  " | " + .Title + " | " + $image_patched + "|" + $image_patched_hash + "|"' < "$TRIVY_SCAN_OUTPUT_FILE">> "$PATCH_REPORT_OUTPUT_FILE"
    done
    echo ">>>>>>>>>>>>>>>>>>> Tag $image_to_patch-patched as secured image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
    echo "FROM $image_to_patch-patched" | DOCKER_BUILDKIT=0 docker build \
      ${DOCKER_LABELS} \
      --label io.sighup.secured.image.created="$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")" \
      --label io.sighup.secured.image.from.hash="$image_to_patch_hash" \
      -t "$secured_image" \
      -f - "$DOCKERFILE_OUTPUT_DIR" &> /dev/null
    secured_labeled_image_hash=$(docker inspect "$secured_image" --format '{{.Id}}')
    sed -i'.unsecured' s#"$image_to_patch-patched"#"$secured_image"# "$PATCH_REPORT_OUTPUT_FILE"
    sed -i'.unsecured' s#"$image_patched_hash"#"$secured_labeled_image_hash"# "$PATCH_REPORT_OUTPUT_FILE"
    rm "$PATCH_REPORT_OUTPUT_FILE.unsecured"
    echo ">>>>>>>>>>>>>>>>>>> Push secure image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
    [[ $DRY_RUN -eq 0 ]] && docker push "$secured_image"
    echo ">>>>>>>>>>>>>>>>>>> CLEANUP $image_to_patch-patched <<<<<<<<<<<<<<<<<<<<<"
    buildctl --addr tcp://127.0.0.1:8888 prune
    docker rmi -f "$image_to_patch-patched"
    echo ">>>>>>>>>>>>>>>>>>> CLEANUP $secured_image <<<<<<<<<<<<<<<<<<<<<"
    docker rmi -f "$secured_image"
  else
    if [ "$image_to_patch" != "$secured_image" ]
    then
      echo ">>>>>>>>>>>>>>>>>>> No CVEs patched in $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
      echo ">>>>>>>>>>>>>>>>>>> Tag $image_to_patch as secured image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
      docker tag "$image_to_patch" "$secured_image"
      echo ">>>>>>>>>>>>>>>>>>> Push secured image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
      [[ $DRY_RUN -eq 0 ]] && docker push "$secured_image"
      echo ">>>>>>>>>>>>>>>>>>> CLEANUP $secured_image <<<<<<<<<<<<<<<<<<<<<"
      docker rmi -f "$secured_image"
      echo ">>>>>>>>>>>>>>>>>>> Update patching error log <<<<<<<<<<<<<<<<<<<<<"
      echo "$secured_image: $(awk -F'Error:' '$0 ~ /Error:/ {print $2}' "$COPA_PATCHING_LOG_FILE")" >> "$PATCH_ERROR_OUTPUT_FILE"
    else
      echo ">>>>>>>>>>>>>>>>>>> $image_to_patch is the same of $secured_image <<<<<<<<<<<<<<<<<<<<<"
    fi
  fi

  echo ">>>>>>>>>>>>>>>>>>> CLEANUP $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
  docker rmi -f "$image_to_patch"
  echo ""
  echo "================================================================"
  echo ""
}

[[ -n $IMAGE_TO_PATCH ]] && patch_image "$IMAGE_TO_PATCH" && exit 0

while IFS= read -r image; do
  patch_image "$image"
done < "$FILE_WITH_IMAGES_LIST_TO_PATCH"
