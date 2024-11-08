#!/bin/bash

source $(dirname $0)/logging.sh

if [ -z $DOCKER_CONFIG ]
then
  warn "missing env var: DOCKER_CONFIG. Set default to $HOME/.docker"
  export DOCKER_CONFIG=$HOME/.docker
fi

function podman_run(){
  docker run --rm -v ${DOCKER_CONFIG}:${DOCKER_CONFIG} -e DOCKER_CONFIG="${DOCKER_CONFIG}" --privileged quay.io/podman/stable:v5.2.5 bash -c "$*"
}

function skopeo_run(){
  docker run --rm -v ${DOCKER_CONFIG}:${DOCKER_CONFIG} -e DOCKER_CONFIG="${DOCKER_CONFIG}" --entrypoint bash quay.io/skopeo/stable:v1.13 -c "$*"
}

function get_architecture_and_digest(){
  local image=$1

  # Fetch the manifest using Podman
  MANIFESTS_AS_JSON=$(podman_run podman manifest inspect ${image} 2> /dev/null | jq -cr '
    if .mediaType == "application/vnd.docker.distribution.manifest.list.v2+json" then
      .manifests | [
        .[] |
        select(.platform.os == "linux") |
        select(.platform.architecture == "amd64" or .platform.architecture == "arm64") |
        {
          "architecture": .platform.architecture,
          "digest": .digest
        }
      ]
    else
      null
    end
  ')

  # If the manifest is null, fall back to Skopeo inspection
  if [ "${MANIFESTS_AS_JSON}" = "null" ]; then
    MANIFESTS_AS_JSON=$(skopeo_run skopeo inspect docker://${image} | jq -cr '[{"digest": .Digest, "architecture": "amd64"}]')
  fi

  # Check if the result is empty or invalid
  if [ -z "$MANIFESTS_AS_JSON" ] || [ "$MANIFESTS_AS_JSON" = "null" ]; then
#    error "unable to retrieve architecture and digest information for image ${image}"
    MANIFESTS_AS_JSON=[]
  fi

  echo "${MANIFESTS_AS_JSON}"
}

