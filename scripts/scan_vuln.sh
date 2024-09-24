#!/bin/bash

KFD_VERSION=$1
[[ -z $KFD_VERSION ]] && echo "Missing KFD VERSION" && exit 1

images_with_tags=$(cat "${KFD_VERSION}/images.txt")
TRIVY_SCAN_OUTPUT_DIR=/tmp/kfd/${KFD_VERSION}
SCAN_RESULT_OUTPUT_FILE=${KFD_VERSION}/README.md
SCAN_ERROR_OUTPUT_FILE=${KFD_VERSION}/scan-error.log

echo "" > "${SCAN_ERROR_OUTPUT_FILE}"

{
  printf "# KFD %s\n\n" "${KFD_VERSION}";
  printf "Last updated %s\n\n" "$(date +'%Y-%m-%d')";
  printf "## CVEs\n\n";
} > "${SCAN_RESULT_OUTPUT_FILE}"

echo "| Image | Hash| Severity | CVE | Reason | Package Affected | Status | Fixed in versions |" >> "${SCAN_RESULT_OUTPUT_FILE}"
echo "| --- | --- | --- | --- | --- | --- | --- | --- |" >> "${SCAN_RESULT_OUTPUT_FILE}"

mkdir -p "$TRIVY_SCAN_OUTPUT_DIR"

for image in $images_with_tags; do
  TRIVY_SCAN_OUTPUT_FILE=/tmp/kfd/${KFD_VERSION}/scan-${image//[:\/]/_}.json

  if ! trivy image --skip-db-update --skip-java-db-update --scanners vuln --no-progress --output "$TRIVY_SCAN_OUTPUT_FILE" --format json --severity CRITICAL "$image"
  then
    echo "$image | ERROR PROCESSING! " >> "${SCAN_ERROR_OUTPUT_FILE}"
  else
    src_image_hash=$(jq -r '.Metadata.ImageID' < "$TRIVY_SCAN_OUTPUT_FILE")
    jq -r --arg image "$image" \
      --arg src_image_hash "$src_image_hash" \
      'try .Results[].Vulnerabilities[] | "| " + $image + " | " + $src_image_hash +" | " + .Severity + " | " + .VulnerabilityID + " | " + .Title + " | " + .PkgName + " " + .InstalledVersion + " | " + .Status + " | " + .FixedVersion + " |" ' < "$TRIVY_SCAN_OUTPUT_FILE" >> "${SCAN_RESULT_OUTPUT_FILE}"
  fi

done

rm -rf "$TRIVY_SCAN_OUTPUT_DIR"
