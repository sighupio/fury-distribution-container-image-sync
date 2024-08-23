#!/bin/bash

if command -v gsed >/dev/null 2>&1; then
    SED_COMMAND='gsed'
else
    SED_COMMAND="sed"
fi

find CVEs -name "images.txt" -exec cat {} + > to_be_patched.txt

#$SED_COMMAND -i 's|registry.sighup.io/fury/|registry.sighup.io/fury/secured/|g' to_be_patched.txt

file="to_be_patched.txt"

docker run --detach --rm --privileged -p 127.0.0.1:8888:8888/tcp --name buildkitd --entrypoint buildkitd moby/buildkit:v0.11.4 --addr tcp://0.0.0.0:8888 # --platform linux/amd64

while IFS= read -r line; do
    secured=$(echo "$line" | sed 's|registry.sighup.io/fury|registry.sighup.io/fury/secured|')
    docker pull $line # --platform linux/amd64
    trivy image -q --vuln-type os --ignore-unfixed -f json -o $(basename $line).json $line # --platform=linux/amd64
    if copa patch -r $(basename $line).json -i $line -a tcp://0.0.0.0:8888 ; then
        echo "############## SUCCESS, will execute:"
        echo "----> docker tag $line-patched $secured"
        echo "----> docker push $secured"
    else
        echo "%%%%%%%%%%%%%% COPA FAILED, will execute:"
        echo "----> docker tag $line $secured"
        echo "----> docker push $secured"
    fi

done < "$file"

docker stop buildkitd
docker rm buildkitd