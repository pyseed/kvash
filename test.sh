#!/bin/bash
export SHKV_STORE="${HOME}/tmp/shkv"

# testKey key expectedValue
testKey () {
    echo "$@"
    echo "$*"
    local key="$1"
    local expectedValue="$2"
    local filePath="${SHKV_STORE}/${key}"

    echo "TEST KEY: key: ${key}, filePath="${filePath}", expected value: ${expectedValue}"
    [ "$(cat ${filePath})" = "${expectedValue}" ] && echo "OK" || echo "FAIL"
}

#
# set
#
set -
./shkv set hello world
set +x
testKey hello world

set -x
./shkv set hello "world test"
set +x
testKey hello "world test"
