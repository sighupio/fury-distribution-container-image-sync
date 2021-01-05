#!/bin/bash

IMAGES=$(yq e '.images | length' images.yml)
for (( c=0; c<${IMAGES}; c++ ))
do
    NAME=$(yq e '.images['"${c}"'].name' images.yml)
    SRC=$(yq e '.images['"${c}"'].source' images.yml)
    DST=$(yq e '.images['"${c}"'].destination' images.yml)
    echo "  - Start ${NAME}"
    docker pull ${SRC}
    docker tag ${SRC} ${DST}
    docker push ${DST}
    echo "  - Finish ${NAME}"
done
