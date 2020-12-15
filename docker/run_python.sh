#!/bin/bash

# Inspect Docker Image by launch a container and enter it.

if [[ -z ${CUDA_VISIBLE_DEVICES} ]]; then
    CUDA_VISIBLE_DEVICES=""
fi

set -eu
CUR_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${CUR_SCRIPT_DIR}/version.sh
GID=$( id -g ${UID} )

#MOUNT_WORKDIR="--volume=${CUR_SCRIPT_DIR}/..:/workspace/charnet:rw"
MOUNT_WORKDIR=""
# Use a larger --shm-size=64gb instead of --ipc=host to avoid shared memory attack.
# SHM_POLICY="--ipc=host"
SHM_POLICY="--shm-size=64gb"
#INTERACTIVE_MODE="-it"
INTERACTIVE_MODE=""

docker run \
--gpus all \
--rm \
${SHM_POLICY} \
${INTERACTIVE_MODE} \
--volume=/dump:/dump:rw \
--volume=/supercam:/supercam:rw \
--volume=/dump/algossd/yliu/output:/output:rw \
--volume=/dump/algossd/yliu/fvcore_cache:/tmp/.torch/fvcore_cache:rw \
--volume=/dump/algossd/yliu/datasets:/datasets:rw \
${MOUNT_WORKDIR} \
-w /workspace/text_rcnn \
-e IMAGE_CACHE_DIR=${IMAGE_CACHE_DIR} \
-e CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES}" \
--entrypoint "python" \
--user ${UID}:${GID} \
${DOCKER_IMAGE_TAG} \
$@
