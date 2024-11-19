#!/bin/bash

RC_ERROR_MISSING_DESTINATION=1  # Define exit code for missing destination
SKOPEO_IMAGE='quay.io/skopeo/stable:v1.16.1'

# Check if second argument ($2) is set to "true", which enables dry mode
if [ $2 = true ]; then
  DRY=true  # Set DRY mode to true
  echo "  - DRY MODE: $DRY"  # Inform the user that dry mode is active
else
  DRY=false  # DRY mode is off
  echo "  - DRY MODE: $DRY"  # Inform the user that dry mode is inactive
fi

# Get the number of images from the input YAML file ($1)
IMAGES=$(yq e '.images | length' $1)

# Loop through each image in the YAML file
for (( c=0; c<${IMAGES}; c++ ))
do
    # Extract various attributes for the image (name, multi-arch)
    NAME=$(yq e '.images['"${c}"'].name' $1)
    MULTI_ARCH=$(yq e '.images['"${c}"'].multi-arch' $1)

    # If MULTI_ARCH is null or empty, set it to true by default
    if [ "$MULTI_ARCH" == "null" ] || [ -z "$MULTI_ARCH" ]; then
      MULTI_ARCH="true"  # Default to true if null or empty
    fi

    # Extract source and context for the sync
    SRC=$(yq e '.images['"${c}"'].source' $1)
    CONTEXT=$(yq e '.images['"${c}"'].build.context' $1)
    echo "  - Start ${NAME}"  # Notify the start of processing this image

    # Get the number of destinations and tags
    DST=$(yq e '.images['"${c}"'].destinations | length' $1)
    TAG=$(yq e '.images['"${c}"'].tag | length' $1)

    # Check if at least one destination is specified
    if [ ${#DST} -lt 1 ]; then
      echo "  - ERROR: at least one destination is required"
      exit $RC_ERROR_MISSING_DESTINATION  # Exit with error code if no destination
    fi

    # Loop through each tag
    for (( t=0; t<${TAG}; t++ ))
    do
        # Initialize flags for layer differences (for both amd64 and arm64)
        AMD64_DIFF=1
        ARM64_DIFF=1
        LOCAL_TAG=$(yq e '.images['"${c}"'].tag['"${t}"']' $1)

        # Check if the context is null and if dry mode is active
        if [ "${CONTEXT}" = "null" ]; then
          if [ ${DRY} = true ]; then
              echo "    - DRY MODE is active, skipping layers check"  # In dry mode, skip layer diff check
          else
              set -x
              # Perform layer diff check for AMD64
              LOCAL_LAYERS=$(docker run --rm "${SKOPEO_IMAGE}" inspect -n --override-os linux --override-arch amd64 docker://${SRC}:${LOCAL_TAG} 2> /dev/null | yq .Layers)
              TARGET_LAYERS=$(docker run --rm "${SKOPEO_IMAGE}" inspect -n --override-os linux --override-arch amd64 docker://$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG} 2> /dev/null | yq .Layers)

              diff <(echo ${LOCAL_LAYERS}) <(echo ${TARGET_LAYERS}) > /dev/null
              AMD64_DIFF=$?  # Store the exit code of diff (0 if no difference)
              echo "    - AMD64 diff exit code is: $AMD64_DIFF"

              # If multi-arch is true, also perform the diff check for ARM64
              ARM64_DIFF=$AMD64_DIFF
              if [ ${MULTI_ARCH} = true ]; then
                LOCAL_LAYERS=$(docker run --rm "${SKOPEO_IMAGE}" inspect -n --override-os linux --override-arch arm64 docker://${SRC}:${LOCAL_TAG} 2> /dev/null | yq .Layers)
                TARGET_LAYERS=$(docker run --rm "${SKOPEO_IMAGE}" inspect -n --override-os linux --override-arch arm64 docker://$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG} 2> /dev/null | yq .Layers)

                diff <(echo ${LOCAL_LAYERS}) <(echo ${TARGET_LAYERS}) > /dev/null
                ARM64_DIFF=$?  # Store the exit code for ARM64 diff
                echo "    - ARM64 diff exit code is: $ARM64_DIFF"
              fi
              set +x
          fi
        fi

        # exit if some error occurs after layers checking
        set -e

        # If no layer differences and dry mode is off, skip syncing
        if [ $AMD64_DIFF -eq 0 ] && [ $ARM64_DIFF -eq 0 ] && [ ${DRY} = false ] && [ ${CONTEXT} = "null" ]; then
          echo "    - Skipping ${SRC}:${LOCAL_TAG} as it is already synced"
        else
          # Handle dry mode and perform either skip or sync actions
          if [ ${DRY} = true ] && [ ${CONTEXT} = "null" ]; then
            echo "    - DRY MODE is active, skipping pull for ${SRC}:${LOCAL_TAG}"  # Skip pull in dry mode
          elif [ ${DRY} = true ] && [ ${CONTEXT} != "null" ]; then
            echo "    - DRY MODE is active, skipping build for ${SRC}:${LOCAL_TAG}"  # Skip build in dry mode
          elif [ ${CONTEXT} = "null" ]; then
            echo "    - Layers are different, syncing ${SRC}:${LOCAL_TAG}"  # Sync the image if layers are different
            if [ ${MULTI_ARCH} = true ]; then
              echo "    - No prepull, sync using skopeo"  # Multi-arch sync using skopeo
            else
              docker pull ${SRC}:${LOCAL_TAG}  # Regular pull if not multi-arch
            fi
          else
            # Handle build arguments if context is specified
            BUILD_ARGS=""
            ARG=$(yq e '.images['"${c}"'].build.args | length' $1)
            for (( a=0; a<${ARG}; a++ ))
            do
                ARG_NAME=$(yq e '.images['"${c}"'].build.args['"${a}"'].name' $1)
                ARG_VALUE=$(yq e '.images['"${c}"'].build.args['"${a}"'].value' $1)
                BUILD_ARGS=$BUILD_ARGS" --build-arg "$ARG_NAME"="$ARG_VALUE
            done

            # Perform multi-arch build if needed
            if [ ${MULTI_ARCH} = true ]; then
              TARGET_IMAGE=$(yq e '.images['"${c}"'].destinations[0]' $1):${LOCAL_TAG}
              docker buildx build --push \
                --platform linux/amd64,linux/arm64 \
                $BUILD_ARGS --build-arg IMAGETAG=${LOCAL_TAG} \
                -t ${TARGET_IMAGE} $(dirname $1)/${CONTEXT}
            else
              docker build $BUILD_ARGS --build-arg IMAGETAG=${LOCAL_TAG} -t ${SRC}:${LOCAL_TAG} $(dirname $1)/${CONTEXT}
            fi
          fi

          # Loop through each destination and push the image
          for (( d=0; d<${DST}; d++ ))
          do
              TO=$(yq e '.images['"${c}"'].destinations['"${d}"']' $1):${LOCAL_TAG}

              # Handle dry mode and skip tag/push
              if [ ${DRY} = true ]; then
                echo "    - DRY MODE is active, skipping tag and push to ${TO}"
              else
                if [ ${MULTI_ARCH} = true ]; then
                  if [ ${CONTEXT} != "null" ]; then
                    if [ ${d} -eq 0 ]; then
                      continue  # Skip the first destination in multi-arch case
                    else
                      SRC=$(yq e '.images['"${c}"'].destinations[0]' $1)  # Use the first destination as source as it as already built previously
                    fi
                  fi
                  # Use skopeo for multi-arch sync
                  echo "    - Syncing image from ${SRC}:${LOCAL_TAG} to ${TO}"
                  docker run -v ./login:/login \
                        --rm \
                        "${SKOPEO_IMAGE}" \
                        copy --authfile=/login/auth.json --multi-arch all \
                        docker://${SRC}:${LOCAL_TAG} docker://${TO}
                else
                  # Regular tag and push for single-arch images
                  docker tag ${SRC}:${LOCAL_TAG} ${TO}
                  docker push ${TO}
                  docker rmi ${TO}
                fi
              fi
            done

          # Handle image removal in dry mode and for multi-arch images
          if [ ${DRY} = true ]; then
            echo "    - DRY MODE is active, skipping image rmi for ${SRC}:${LOCAL_TAG}"
          else
            if [ ${MULTI_ARCH} = true ]; then
              echo "not removing images while using skopeo"  # Skip image removal for multi-arch sync
            else
              docker rmi ${SRC}:${LOCAL_TAG}  # Regular image removal if not multi-arch
            fi
          fi
        fi
        # remove error exit if some error occurs to avoid exiting during layer checks
        set +x
    done
    echo "  - Finish ${NAME}"  # Notify the end of processing for this image
done
