#!/bin/bash

KFD_VERSION=$1
[[ -z $KFD_VERSION ]] && echo "Missing KFD VERSION" && exit 1

images_with_tags=$(cat "${KFD_VERSION}/images.txt")
TRIVY_SCAN_OUTPUT_DIR=/tmp/kfd/${KFD_VERSION}
SCAN_RESULT_OUTPUT_FILE=${KFD_VERSION}/README.md
SCAN_ERROR_OUTPUT_FILE=${KFD_VERSION}/error.log

echo "" > ${SCAN_ERROR_OUTPUT_FILE}

printf "# KFD ${KFD_VERSION}\n\n" > ${SCAN_RESULT_OUTPUT_FILE}
printf "Updated to $(date +'%Y-%m-%d')\n\n" >> ${SCAN_RESULT_OUTPUT_FILE}
printf "## CVEs\n\n" >> ${SCAN_RESULT_OUTPUT_FILE}

echo "| Image | Severity | CVE | Reason | Package Affected | Status | Fixed in versions |" >> ${SCAN_RESULT_OUTPUT_FILE}
echo "| --- | --- | --- | --- | --- | --- | --- |" >> ${SCAN_RESULT_OUTPUT_FILE}

mkdir -p $TRIVY_SCAN_OUTPUT_DIR

for image in $images_with_tags; do
  TRIVY_SCAN_OUTPUT_FILE=/tmp/kfd/${KFD_VERSION}/scan-${image//[:\/]/_}.json
  trivy image --platform=linux/amd64  --no-progress --output $TRIVY_SCAN_OUTPUT_FILE --format json --severity CRITICAL "$image"
  if [ $? -ne 0 ]; then
    echo "$image | ERROR PROCESSING! " >> $SCAN_ERROR_OUTPUT_FILE
  else
    cat $TRIVY_SCAN_OUTPUT_FILE | jq -r --arg image $image 'try .Results[].Vulnerabilities[] | "| " + $image + " | " + .Severity + " | " + .VulnerabilityID + " | " + .Title + " | " + .PkgName + " " + .InstalledVersion + " | " + .Status + " | " + .FixedVersion + " |" ' >> ${SCAN_RESULT_OUTPUT_FILE}
  fi

done

rm -rf $TRIVY_SCAN_OUTPUT_DIR