#!/bin/bash
set -eu
CUR_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

bash ${CUR_SCRIPT_DIR}/build.sh && \
bash ${CUR_SCRIPT_DIR}/run_python.sh $@