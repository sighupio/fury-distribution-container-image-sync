#!/bin/bash

source $(dirname $0)/logging.sh

if [ -z $DOCKER_CONFIG ]
then
  fail "missing env var: DOCKER_CONFIG"
fi

function podman_run(){
  docker run --rm -v ${DOCKER_CONFIG}:${DOCKER_CONFIG} -e DOCKER_CONFIG="${DOCKER_CONFIG}" quay.io/podman/stable:v5.2.5 bash -c "$*"
}

function skopeo(){
  docker run --rm -v ${DOCKER_CONFIG}:${DOCKER_CONFIG} -e DOCKER_CONFIG="${DOCKER_CONFIG}" quay.io/skopeo/stable:v1.13 bash -c "$*"
}

function get_manifest_architectures_from_podman(){
  jq -cr '
    .manifests // [{"platform":{"os": "linux", "architecture": "amd64"}}] |
    .[] | select(.platform.os == "linux") |
    select(.platform.architecture == "amd64" or .platform.architecture == "arm64") |
    .platform.architecture
  '
}
