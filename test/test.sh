#!/bin/bash
export SHKV_STORE="${HOME}/tmp/shkv"
anyFail=""

setKey () {
    local key="$1"
    local filePath="${SHKV_STORE}/${key}"
    local value="$2"

    echo "SET KEY: key: ${key}, filePath=${filePath}, value: ${value}"
    echo  -n "${value}" > "${filePath}"
}

# testKey key testFilePath
testKey () {
    local key="$1"
    local filePath="${SHKV_STORE}/${key}"
    local testFilePath="./check/$2"

    echo "TEST KEY: key: ${key}, filePath=${filePath}"
    if diff -u "${filePath}" "${testFilePath}"; then
        echo "SUCCESS"
    else
        echo "FAIL"
        anyFail="true"
    fi
}

#
# set
#
echo ""
echo "set 1"
set -
../shkv set hello world
set +x
testKey hello set1.txt

echo ""
echo "set 2"
set -x
../shkv set hello "world test"
set +x
testKey hello set2.txt


#
# append
#
echo ""
echo "append"
setKey hello world
cat /home/vgreiner/tmp/shkv/hello
set -
../shkv append hello "append entry"
set +x
testKey hello append.txt

echo ""
echo "appendr"
setKey hello world
set -
../shkv appendr hello "appendr entry"
set +x
testKey hello appendr.txt

echo ""
echo ""
[ "${anyFail}" = "true" ] && echo "TEST FAILED" || echo "TEST SUCCESS"
