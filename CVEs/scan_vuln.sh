#!/bin/bash

KFD_VERSION=
IMAGE_LIST_FILE=
SCAN_RESULT_OUTPUT_FILE=

source $(dirname $0)/utils.sh
source $(dirname $0)/logging.sh

function usage() {
    echo "Usage: $0 -v KFD_VERSION [-l IMAGE_LIST_FILE] [-o SCAN_RESULT_OUTPUT_FILE]"
}

while getopts ":v:l:o:" o; do
    case "${o}" in
        v)
            KFD_VERSION=${OPTARG}
            ;;
        l)
            IMAGE_LIST_FILE=${OPTARG}
            ;;
        o)
            SCAN_RESULT_OUTPUT_FILE=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

[[ -z ${KFD_VERSION} ]] && fail "Missing KFD VERSION"
[[ -z ${IMAGE_LIST_FILE} ]] && IMAGE_LIST_FILE="${KFD_VERSION}/images.txt"
[[ -z ${SCAN_RESULT_OUTPUT_FILE} ]] && SCAN_RESULT_OUTPUT_FILE="${KFD_VERSION}/CVEs.md"

IMAGE_LIST=$(cat "$IMAGE_LIST_FILE")
TRIVY_SCAN_OUTPUT_DIR=${KFD_VERSION}/.scan
SCAN_ERROR_OUTPUT_FILE=${KFD_VERSION}/$(basename ${SCAN_RESULT_OUTPUT_FILE}).scan-error.log

mkdir -p $(dirname ${SCAN_RESULT_OUTPUT_FILE}) "${TRIVY_SCAN_OUTPUT_DIR}"
echo "" > "${SCAN_ERROR_OUTPUT_FILE}"

{
  printf "# %s %s\n\n" " $(basename ${SCAN_RESULT_OUTPUT_FILE}) ${KFD_VERSION}";
  printf "Last updated %s\n\n" "$(date +'%Y-%m-%d')";
  printf "## CVEs\n\n";
} > "${SCAN_RESULT_OUTPUT_FILE}"

echo "| Image | Arch | Hash | Severity | CVE | Reason | Package Affected | Status | Fixed in versions |" >> "${SCAN_RESULT_OUTPUT_FILE}"
echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "${SCAN_RESULT_OUTPUT_FILE}"

mkdir -p "${TRIVY_SCAN_OUTPUT_DIR}"

for image in $IMAGE_LIST; do
  info "Looking for linux architectures available for ${image}"
  ARCHITECTURES=$(podman_run podman manifest inspect ${image} | grep -v WARN | get_manifest_architectures_from_podman)
  info "${image} - linux architectures found: ${ARCHITECTURES//[$'\r\n']/ } "
  for ARCHITECTURE in ${ARCHITECTURES[@]}
  do
    TRIVY_SCAN_OUTPUT_FILE="${TRIVY_SCAN_OUTPUT_DIR}/scan-${image//[:\/]/_}-${ARCHITECTURE}.json"

    info "Looking for CVEs in $image for linux/${ARCHITECTURE}"
    if ! trivy image --skip-db-update --skip-java-db-update --scanners vuln --no-progress --output "$TRIVY_SCAN_OUTPUT_FILE" --format json --severity CRITICAL "$image" --platform linux/${ARCHITECTURE}
    then
      error "trivy failed to scan $image"
      echo "$image | ERROR PROCESSING! " >> "${SCAN_ERROR_OUTPUT_FILE}"
    else
      src_image_hash=$(jq -r '.Metadata.ImageID' < "$TRIVY_SCAN_OUTPUT_FILE")
      jq -r --arg image "$image" \
        --arg src_image_hash "$src_image_hash" \
        --arg src_image_arch ${ARCHITECTURE} \
        'try .Results[].Vulnerabilities[] | "| " + $image + " | " + $src_image_arch + " | " + $src_image_hash + " | " + .Severity + " | " + .VulnerabilityID + " | " + .Title + " | " + .PkgName + " " + .InstalledVersion + " | " + .Status + " | " + .FixedVersion + " |" ' < "$TRIVY_SCAN_OUTPUT_FILE" >> "${SCAN_RESULT_OUTPUT_FILE}"
    fi
    trivy clean --scan-cache
  done
done
rm -rf "${TRIVY_SCAN_OUTPUT_DIR}"
