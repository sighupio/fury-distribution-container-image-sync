#!/bin/bash

# if $2 is not empty, set a variable DRY to true
if [ $2 = true  ]; then
  DRY=true
  echo "  - DRY MODE: $DRY"
else
  DRY=false
  echo "  - DRY MODE: $DRY"
fi

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
        # if DRY is true, print the command
        if [ ${DRY} = true ]; then
            echo "    - DRY MODE is active, skipping layers check"
        else
            LOCAL_LAYERS=$(skopeo inspect --override-os linux docker://${SRC}:${LOCAL_TAG} 2> /dev/null | yq .Layers)
            TARGET_LAYERS=$(skopeo inspect --override-os linux docker://$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG} 2> /dev/null | yq .Layers)

            diff <(echo ${LOCAL_LAYERS}) <(echo ${TARGET_LAYERS}) > /dev/null
        fi

        if [ $? -eq 0 ] && [ ${DRY} = false ]; then
          echo "    - Skipping ${SRC}:${LOCAL_TAG} as it is already synced"
        else
          if [ ${DRY} = true ]; then
            echo "    - DRY MODE is active, skipping pull for ${SRC}:${LOCAL_TAG}"
          else
            echo "    - Layer are different, syncing ${SRC}:${LOCAL_TAG}"
            docker pull ${SRC}:${LOCAL_TAG}
          fi

          for (( d=0; d<${DST}; d++ ))
            do
              TO=$(yq e '.images['"${c}"'].destinations['"${d}"']' $1):${LOCAL_TAG}

              if [ ${DRY} = true ]; then
                echo "    - DRY MODE is active, skipping tag and push to ${TO}"
              else
                echo "    - Tagging ${SRC}:${LOCAL_TAG} as ${TO} and pushing"
                docker tag ${SRC}:${LOCAL_TAG} ${TO}
                docker push ${TO}
                docker rmi ${TO}
              fi
            done
          if [ ${DRY} = true ]; then
            echo "    - DRY MODE is active, skipping image rmi for ${SRC}:${LOCAL_TAG}"
          else
            echo "Something"
            docker rmi ${SRC}:${LOCAL_TAG}
          fi
        fi
    done
    echo "  - Finish ${NAME}"
done
