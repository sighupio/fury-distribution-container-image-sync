#!/bin/bash

KFD_VERSION=$1
[[ -z $KFD_VERSION ]] && echo "Missing KFD VERSION" && exit 1

TRIVY_SCAN_OUTPUT_DIR=${KFD_VERSION}/.patching/scan
COPA_PATCH_OUTPUT_DIR=${KFD_VERSION}/.patching/patch
DOCKERFILE_OUTPUT_DIR=${KFD_VERSION}/.patching/dockerfile
FILE_WITH_IMAGES_LIST_TO_PATCH=${KFD_VERSION}/images.txt
PATCH_REPORT_OUTPUT_FILE=${KFD_VERSION}/PATCHED.md
PATCH_ERROR_OUTPUT_FILE=${KFD_VERSION}/patch-error.log

if [ -z "$(docker ps -f name=buildkitd -q)" ]
then
  echo ">>>>>>>>>>>>>>>>>>> Start buildkitd instance for COPA <<<<<<<<<<<<<<<<<<<<<"
  docker run --detach --rm --privileged -p 127.0.0.1:8888:8888/tcp --name buildkitd --entrypoint buildkitd moby/buildkit:v0.11.4 --addr tcp://0.0.0.0:8888 # --platform linux/amd64
fi

echo -n "" > "${PATCH_ERROR_OUTPUT_FILE}"

mkdir -p "$TRIVY_SCAN_OUTPUT_DIR" "$COPA_PATCH_OUTPUT_DIR" "$DOCKERFILE_OUTPUT_DIR"

{
printf "# KFD %s\n\n" "${KFD_VERSION}";
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
  image_to_patch="$secured_image"

  DOCKER_PULL_OUTPUT_FILE=${KFD_VERSION}/${image_to_patch//[:\/]/_}-image-pull.log

  if ! docker pull "$image_to_patch" > "${DOCKER_PULL_OUTPUT_FILE}" 2>&1
  then
    image_to_patch="$image"
    if ! docker pull "$image_to_patch" >> "${DOCKER_PULL_OUTPUT_FILE}" 2>&1
    then
      echo ">>>>>>>>>>>>>>>>>>> Failed pull $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
      cat "${DOCKER_PULL_OUTPUT_FILE}"
      return 1
    fi
  fi
  TRIVY_SCAN_OUTPUT_FILE=$TRIVY_SCAN_OUTPUT_DIR/${image_to_patch//[:\/]/_}.json
  COPA_REPORT_OUTPUT_FILE=$COPA_PATCH_OUTPUT_DIR/${image_to_patch//[:\/]/_}.vex.json
  COPA_PATCHING_LOG_FILE=$COPA_PATCH_OUTPUT_DIR/${image_to_patch//[:\/]/_}.log
  echo ">>>>>>>>>>>>>>>>>>> Scan $image_to_patch for CVEs <<<<<<<<<<<<<<<<<<<<<"
  trivy image --skip-db-update --skip-java-db-update --scanners vuln -q --vuln-type os --ignore-unfixed -f json -o "${TRIVY_SCAN_OUTPUT_FILE}" "$image_to_patch" # --platform=linux/amd64
  trivy clean --scan-cache
  echo ">>>>>>>>>>>>>>>>>>> Patching CVEs for $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
  copa patch -r "${TRIVY_SCAN_OUTPUT_FILE}" -i "$image_to_patch" --format="openvex" --output "$COPA_REPORT_OUTPUT_FILE" -a tcp://127.0.0.1:8888 2>&1 | tee "$COPA_PATCHING_LOG_FILE"
  copa_exit_code=${PIPESTATUS[0]}

  if [ "$copa_exit_code" -eq 0 ]
  then
    FIXED_CVES=$(jq '.statements[] | select(.status=="fixed") | .vulnerability."@id"' -r < "$COPA_REPORT_OUTPUT_FILE" | sort -r)
    DOCKER_LABELS=
    secured_image_hash=$(docker inspect "$image_to_patch-patched" --format '{{.Id}}')
    echo ">>>>>>>>>>>>>>>>>>> Update patching report for $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
    for FIXED_CVE in ${FIXED_CVES[@]}
    do
      DOCKER_LABELS="--label io.sighup.secured.${FIXED_CVE}=fixed ${DOCKER_LABELS}"
      src_image_hash=$(jq -r '.Metadata.ImageID' < "$TRIVY_SCAN_OUTPUT_FILE")
      jq -r \
      --arg image_to_patch "$image_to_patch" \
      --arg cve "$FIXED_CVE" \
      --arg image_patched "$secured_image" \
      --arg src_image_hash "$src_image_hash" \
      --arg secured_image_hash "$secured_image_hash" \
      '[try .Results[].Vulnerabilities[] | select(.VulnerabilityID==$cve)][0] | "|" + $image_to_patch + " | " + $src_image_hash + " | " + .VulnerabilityID + " | " +  .Severity +  " | " + .Title + " | " + $image_patched + "|" + $secured_image_hash + "|"' < "$TRIVY_SCAN_OUTPUT_FILE">> "$PATCH_REPORT_OUTPUT_FILE"
    done
    echo ">>>>>>>>>>>>>>>>>>> Tag secure image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
    echo "FROM $image-patched" | DOCKER_BUILDKIT=0 docker build \
      ${DOCKER_LABELS} \
      --label io.sighup.secured.image.created="$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")" \
      -t "$secured_image" \
      -f - "$DOCKERFILE_OUTPUT_DIR" &> /dev/null
    secured_labeled_image_hash=$(docker inspect "$secured_image" --format '{{.Id}}')
    sed -i"" s#"$secured_image_hash"#"$secured_labeled_image_hash"# "$PATCH_REPORT_OUTPUT_FILE"
    echo ">>>>>>>>>>>>>>>>>>> Push secure image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
    docker push "$secured_image"
  else
    if [ "$image_to_patch" != "$secured_image" ]
    then
      echo ">>>>>>>>>>>>>>>>>>> Tag secure image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
      docker tag "$image" "$secured_image"
      echo ">>>>>>>>>>>>>>>>>>> Push secure image: $secured_image <<<<<<<<<<<<<<<<<<<<<"
      docker push "$secured_image"
    fi
    echo "$secured_image: $(awk -F'Error:' '$0 ~ /Error:/ {print $2}' "$COPA_PATCHING_LOG_FILE")" >> "$PATCH_ERROR_OUTPUT_FILE"
  fi

  echo ">>>>>>>>>>>>>>>>>>> CLEANUP $image_to_patch <<<<<<<<<<<<<<<<<<<<<"
  docker rmi -f "$image_to_patch"
  buildctl --addr tcp://127.0.0.1:8888 prune
  if [ "$secured_image" != "$image_to_patch" ]
  then
    echo ">>>>>>>>>>>>>>>>>>> CLEANUP $secured_image <<<<<<<<<<<<<<<<<<<<<"
    docker rmi -f "$secured_image"
  fi
  echo ""
  echo "================================================================"
  echo ""
}

while IFS= read -r image; do
  patch_image "$image"
done < "$FILE_WITH_IMAGES_LIST_TO_PATCH"

