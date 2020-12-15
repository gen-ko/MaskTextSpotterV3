#!/bin/bash

# Use ./docker/build.sh -n to build without using cached intermediate containers.

set -eu

CUR_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $CUR_SCRIPT_DIR/version.sh
GID=$( id -g ${UID} )
GIDS=$( id -G ${UID} )

# Use private key to access internal git repos, eg. AmbaJson. 
# Must be removed by `rm /root/.ssh/id_rsa && rm /root/.ssh/known_hosts`
# before any intermediate containers are cached.
SSH_PRIVATE_KEY=$( cat ${HOME}/.ssh/id_rsa )


# Parse Script Arguments
NO_CACHE=""
while getopts "n" opt
do
    case $opt in
    (n) NO_CACHE=--no-cache ;;
    (*) printf "Illegal option '-%s'\n" "$opt" && exit 1 ;;
    esac
done


docker build \
    -t ${DOCKER_IMAGE_TAG} \
    -f ${CUR_SCRIPT_DIR}/Dockerfile \
    --build-arg SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY}" \
    ${NO_CACHE} \
    ${CUR_SCRIPT_DIR}/..
