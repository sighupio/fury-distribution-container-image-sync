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
    MULTI_ARCH=$(yq e '.images['"${c}"'].multi-arch' $1)
    SRC=$(yq e '.images['"${c}"'].source' $1)
    CONTEXT=$(yq e '.images['"${c}"'].build.context' $1)
    echo "  - Start ${NAME}"
    DST=$(yq e '.images['"${c}"'].destinations | length' $1)
    TAG=$(yq e '.images['"${c}"'].tag | length' $1)
    for (( t=0; t<${TAG}; t++ ))
    do
        LOCAL_TAG=$(yq e '.images['"${c}"'].tag['"${t}"']' $1)
        # if DRY is true, print the command
        if [ "${CONTEXT}" = "null" ]; then
          if [ ${DRY} = true ]; then
              echo "    - DRY MODE is active, skipping layers check"
          else
              LOCAL_LAYERS=$(docker run --rm quay.io/skopeo/stable:v1.13 inspect -n --override-os linux --override-arch amd64 docker://${SRC}:${LOCAL_TAG} 2> /dev/null | yq .Layers)
              TARGET_LAYERS=$(docker run --rm quay.io/skopeo/stable:v1.13 inspect -n --override-os linux --override-arch amd64 docker://$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG} 2> /dev/null | yq .Layers)

              diff <(echo ${LOCAL_LAYERS}) <(echo ${TARGET_LAYERS}) > /dev/null
              AMD64_DIFF=$?

              echo "    - AMD64 diff exit code is: $AMD64_DIFF"
              
              # if not multiarch, the value can be the same
              ARM64_DIFF=$AMD64_DIFF
              if [ ${MULTI_ARCH} = true ]; then
                LOCAL_LAYERS=$(docker run --rm quay.io/skopeo/stable:v1.13 inspect -n --override-os linux --override-arch arm64 docker://${SRC}:${LOCAL_TAG} 2> /dev/null | yq .Layers)
                TARGET_LAYERS=$(docker run --rm quay.io/skopeo/stable:v1.13 inspect -n --override-os linux --override-arch arm64 docker://$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG} 2> /dev/null | yq .Layers)

                diff <(echo ${LOCAL_LAYERS}) <(echo ${TARGET_LAYERS}) > /dev/null
                ARM64_DIFF=$?

                echo "    - ARM64 diff exit code is: $ARM64_DIFF"
              fi
          fi
        fi

        if [ $AMD64_DIFF -eq 0 ] && [ $ARM64_DIFF -eq 0 ] && [ ${DRY} = false ] && [ ${CONTEXT} = "null" ]; then
          echo "    - Skipping ${SRC}:${LOCAL_TAG} as it is already synced"
        else
          if [ ${DRY} = true ] && [ ${CONTEXT} = "null" ]; then
            echo "    - DRY MODE is active, skipping pull for ${SRC}:${LOCAL_TAG}"
          elif [ ${DRY} = true ] && [ ${CONTEXT} != "null" ]; then
            echo "    - DRY MODE is active, skipping build for ${SRC}:${LOCAL_TAG}"
          elif [ ${CONTEXT} = "null" ]; then
            echo "    - Layers are different, syncing ${SRC}:${LOCAL_TAG}"
            if [ ${MULTI_ARCH} = true ]; then
              echo "    - No prepull, sync using skopeo"
            else
              docker pull ${SRC}:${LOCAL_TAG}
            fi
            # 
          else
            BUILD_ARGS=""
            ARG=$(yq e '.images['"${c}"'].build.args | length' $1)
            for (( a=0; a<${ARG}; a++ ))
              do
                ARG_NAME=$(yq e '.images['"${c}"'].build.args['"${a}"'].name' $1)
                ARG_VALUE=$(yq e '.images['"${c}"'].build.args['"${a}"'].value' $1)
                BUILD_ARGS=$BUILD_ARGS" --build-arg "$ARG_NAME"="$ARG_VALUE
            done
            if [ ${MULTI_ARCH} = true ]; then
              echo "    - Build not supported yet on multi-arch"
              exit 100
            else
              docker build $BUILD_ARGS --build-arg IMAGETAG=${LOCAL_TAG} -t ${SRC}:${LOCAL_TAG} $(dirname $1)/${CONTEXT}
            fi
          fi

          for (( d=0; d<${DST}; d++ ))
          do
              TO=$(yq e '.images['"${c}"'].destinations['"${d}"']' $1):${LOCAL_TAG}

              if [ ${DRY} = true ]; then
                echo "    - DRY MODE is active, skipping tag and push to ${TO}"
              else
                echo "    - Syncing image from ${SRC}:${LOCAL_TAG} to ${TO}"
                if [ ${MULTI_ARCH} = true ]; then
                  docker run -v ./login:/login \
                        --rm \
                        quay.io/skopeo/stable:v1.13 \
                        copy --authfile=/login/auth.json --multi-arch all \
                        docker://${SRC}:${LOCAL_TAG} docker://${TO}
                else
                  docker tag ${SRC}:${LOCAL_TAG} ${TO}
                  docker push ${TO}
                  docker rmi ${TO}
                fi
              fi
            done
          if [ ${DRY} = true ]; then
            echo "    - DRY MODE is active, skipping image rmi for ${SRC}:${LOCAL_TAG}"
          else
            if [ ${MULTI_ARCH} = true ]; then
              echo "not removing images while using skopeo"
            else
              docker rmi ${SRC}:${LOCAL_TAG}
            fi
          fi
        fi
    done
    echo "  - Finish ${NAME}"
done
