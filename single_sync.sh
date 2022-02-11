#!/bin/bash

IMAGES=$(yq e '.images | length' $1)
for (( c=0; c<${IMAGES}; c++ ))
do
    NAME=$(yq e '.images['"${c}"'].name' $1)
    SRC=$(yq e '.images['"${c}"'].source' $1)
    echo "  - Start ${NAME}"
    DST=$(yq e '.images['"${c}"'].destinations | length' $1)
    TAG=$(yq e '.images['"${c}"'].tag | length' $1)
    for (( t=0; t<${TAG}; t++ ))
    do
        LOCAL_TAG=$(yq e '.images['"${c}"'].tag['"${t}"']' $1)
        #docker pull ${SRC}:${LOCAL_TAG}
        for (( d=0; d<${DST}; d++ ))
          do
            TO=$(yq e '.images['"${c}"'].destinations['"${d}"']' $1):${LOCAL_TAG}
            #docker tag ${SRC}:${LOCAL_TAG} ${TO}
            #docker push ${TO}
            #docker rmi ${TO}
          done
        #docker rmi ${SRC}:${LOCAL_TAG}
    done
    echo "  - Finish ${NAME}"
done
