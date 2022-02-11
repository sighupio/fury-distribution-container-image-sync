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
        LOCAL_LAYERS=$(skopeo inspect --override-os linux docker://${SRC}:${LOCAL_TAG} 2> /dev/null | yq .Layers)
        TARGET_LAYERS=$(skopeo inspect --override-os linux docker://$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG} 2> /dev/null | yq .Layers)

        diff <(echo ${LOCAL_LAYERS}) <(echo ${TARGET_LAYERS}) > /dev/null

        if [ $? -eq 0 ]; then
          echo "    - Skipping ${SRC}:${LOCAL_TAG} as it is already synced"
        else
          echo "    - Layer are different, syncing ${SRC}:${LOCAL_TAG}"
          docker pull ${SRC}:${LOCAL_TAG}
          for (( d=0; d<${DST}; d++ ))
            do
              TO=$(yq e '.images['"${c}"'].destinations['"${d}"']' $1):${LOCAL_TAG}
              docker tag ${SRC}:${LOCAL_TAG} ${TO}
              docker push ${TO}
              docker rmi ${TO}
            done
          docker rmi ${SRC}:${LOCAL_TAG}
        fi
    done
    echo "  - Finish ${NAME}"
done

# check if two string are equals
# if [ "$1" == "$2" ]; then