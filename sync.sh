#!/bin/bash

IMAGES=$(yq e '.images | length' images.yml)
for (( c=0; c<${IMAGES}; c++ ))
do
    NAME=$(yq e '.images['"${c}"'].name' images.yml)
    SRC=$(yq e '.images['"${c}"'].source' images.yml)
    echo "  - Start ${NAME}"
    docker pull ${SRC}
    DST=$(yq e '.images['"${c}"'].destination | length' images.yml)
    for (( d=0; d<${DST}; d++ ))
    do
        TO=$(yq e '.images['"${c}"'].destination['"${d}"']' images.yml)
        docker tag ${SRC} ${TO}
        docker push ${TO}
    done
    echo "  - Finish ${NAME}"
done
