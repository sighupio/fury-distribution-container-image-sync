#!/bin/bash

images_with_tags=$(cat images.txt)

echo "" > scan_results.txt

for line in $images_with_tags; do
  trivy image --platform=linux/amd64  --no-progress --output scan.tmp --format json --severity CRITICAL "$line"
  if [ $? -ne 0 ]; then
    echo "$line | ERROR PROCESSING! " >> scan_results.txt
  else
    cat scan.tmp | jq -r --arg line $line 'try .Results[].Vulnerabilities[] |  $line + " | " + .Severity + " " + .VulnerabilityID + " | " + .Title + " | " + .PkgName + " " + .InstalledVersion + " | " + .Status + " | " + .FixedVersion ' >> scan_results.txt
  fi
  
done


echo "" > README.md

echo "| Image | CVE | Reason | Package Affected | Status | Fixed in versions |" >> README.md
echo "| --- | --- | --- | --- | --- | --- |" >> README.md

file="scan_results.txt"

while IFS= read -r line; do
    echo "| $line |" >> README.md
done < "$file"
