#!/bin/bash
export SHKV_STORE="${HOME}/tmp/shkv"

# testKey key expectedValue
testKey () {
    local key="$1"
    local expectedValue="$2"

    echo "TEST KEY: key: ${key}, expected value: ${expectedValue}"
    local filePath="${SHKV_STORE}/${key}"
    local value=$(cat "${filePath}")
    echo "=> path: ${filePath}, value: ${value}"
    [ "${value}" = "${expectedValue}" ] && echo "OK" || echo "FAIL"
}

#
# set
#
set -
./shkv set hello world
set +x
testKey hello world

#set -x
#./shkv set hello "world test"
#set +x
#testKey hello "world test"
