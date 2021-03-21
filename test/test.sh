#!/bin/bash
export SHKV_STORE="${HOME}/tmp/shkv"
anyFail=""
resultOutputFile=/tmp/shkv_result.txt

# force key value
# setKey key value
setKey () {
    local key="$1"
    local filePath="${SHKV_STORE}/${key}"
    local value="$2"

    echo "setKey / key: ${key}, filePath=${filePath}, value: ${value}"
    echo  -n "${value}" > "${filePath}"
}

# testKey key testFilePath
testKey () {
    local key="$1"
    local filePath="${SHKV_STORE}/${key}"
    local testFilePath="./check/$2"

    echo "testKey / key: ${key}, filePath=${filePath}"
    cmpFile "${filePath}" "${testFilePath}"
}

# cmpFile result expected
cmpFile () {
    local result="$1"
    local expected="$2"

    echo "cmpFile / result: ${result}, expected=${expected}"
    if diff -u "${result}" "${expected}"; then
        echo "SUCCESS"
    else
        echo "FAIL"
        anyFail="true"
    fi
}

# cmpFile result expected
cmpResult () {
    local result="$1"
    local expected="$1"

    if [ "${result}" = "${expected}" ]; then
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
../shkv set hello world
testKey hello set1.txt

echo ""
echo "set 2"
../shkv set hello "world test"
testKey hello set2.txt


#
# append
#
echo ""
echo "append from empty"
rm "${SHKV_STORE}/hello"
../shkv append hello "append entry"
testKey hello appendFromEmpty.txt
echo "append"
setKey hello world
cat /home/vgreiner/tmp/shkv/hello
../shkv append hello "append entry"
testKey hello append.txt

echo ""
echo "appendr from empty"
rm "${SHKV_STORE}/hello"
../shkv appendr hello "appendr entry"
testKey hello appendrFromEmpty.txt
echo "appendr"
setKey hello world
../shkv appendr hello "appendr entry"
testKey hello appendr.txt


#
# get
#
echo ""
echo "get"
setKey hello world
result=$(../shkv get hello)
cmpResult "${result}" world


#
# path
#
echo ""
echo "path"
result=$(../shkv path hello)
cmpResult "${result}" "${SHKV_STORE}/hello"


#
# del
#
echo ""
echo "del"
setKey hello world
../shkv del hello
if [ ! -f "${SHKV_STORE}/hello" ]; then
    echo "SUCCESS"
else
    echo "FAIL"
    anyFail="true"
fi


#
# list add
#
echo ""
echo "list add"
rm "${SHKV_STORE}/hello" 2> /dev/null
../shkv list add hello item1
testKey hello listAdd1.txt

# item2
../shkv list add hello item2
testKey hello listAdd2.txt


#
# list del
#
echo ""
echo "list del"
setKey hello item1
../shkv list del hello item1
testKey hello listDel1.txt


#
# list foreach
#
callback1 () {
    echo "callback1: $1"
    echo "callback1: $1" >> /tmp/shkv_foreach.txt
}
export -f callback1

echo ""
echo "list for"
cat ./dataset/foreach.txt > "${SHKV_STORE}/hello"
rm /tmp/shkv_foreach.txt 2> /dev/null
../shkv list foreach hello callback1
cmpFile /tmp/shkv_foreach.txt ./check/foreach.txt
rm /tmp/shkv_foreach.txt 2> /dev/null


#
# dict set
#
echo ""
echo "dict set"
rm "${SHKV_STORE}/hello" 2> /dev/null
../shkv dict set hello one oneword "comment of one"
../shkv dict set hello two twoword "comment of two"
testKey hello dictSet.txt


echo ""
echo ""
[ "${anyFail}" = "true" ] && echo "TEST FAILED" || echo "TEST SUCCESS"
