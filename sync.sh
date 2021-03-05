#!/bin/bash

IMAGES=$(yq e '.images | length' images.yml)
for (( c=0; c<${IMAGES}; c++ ))
do
    NAME=$(yq e '.images['"${c}"'].name' images.yml)
    SRC=$(yq e '.images['"${c}"'].source' images.yml)
    echo "  - Start ${NAME}"
    DST=$(yq e '.images['"${c}"'].destination | length' images.yml)
    TAG=$(yq e '.images['"${c}"'].tag | length' images.yml)
    for (( t=0; t<${TAG}; t++ ))
    do
        LOCAL_TAG=$(yq e '.images['"${c}"'].tag['"${t}"']' images.yml)
        docker pull ${SRC}:${LOCAL_TAG}
        for (( d=0; d<${DST}; d++ ))
          do
            TO=$(yq e '.images['"${c}"'].destination['"${d}"']' images.yml):${LOCAL_TAG}
            docker tag ${SRC}:${LOCAL_TAG} ${TO}
            docker push ${TO}
            #echo tag ${SRC}:${LOCAL_TAG} to ${TO}
            #echo push to ${TO}
          done
    done
    echo "  - Finish ${NAME}"
done
