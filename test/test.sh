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

# beginTest key
beginTest () {
    local key="$1"

    echo ""
    echo "----------"
    echo "${key}"
    echo "----------"
    echo ""
    rm "${SHKV_STORE}/${key}" 2> /dev/null
}

# endTest key
endTest () {
    local key="$1"

    echo ">"
    cat "${SHKV_STORE}/${key}"
    rm "${SHKV_STORE}/${key}" 2> /dev/null
    echo "--"
    echo ""
}

#
# set
#
beginTest test_set

echo ""
echo "set 1"
../shkv set test_set world
testKey test_set set1.txt

echo ""
echo "set 2"
../shkv set test_set "world test"
testKey test_set set2.txt

endTest test_set


#
# append from empy
#
beginTest test_append_from_empty

../shkv append test_append_from_empty "append entry"
testKey test_append_from_empty appendFromEmpty.txt

endTest test_append_from_empty


#
# append
#
beginTest test_append

setKey append world
../shkv append append "append entry"
testKey append append.txt

endTest test_append


#
# appendr from empty
#
beginTest test_appendr_from_empty

../shkv appendr test_appendr_from_empty "appendr entry"
testKey test_appendr_from_empty appendrFromEmpty.txt

endTest test_appendr_from_empty


#
# appendr
#
beginTest test_appendr

echo ""
echo "appendr"
setKey test_appendr world
../shkv appendr test_appendr "appendr entry"
testKey test_appendr appendr.txt

endTest test_appendr


#
# get
#
beginTest test_get

setKey test_get world
result=$(../shkv get test_get)
cmpResult "${result}" world

endTest test_get


#
# path
#
beginTest test_path

result=$(../shkv path test_path)
cmpResult "${result}" "${SHKV_STORE}/test_path"

endTest test_path


#
# del
#
beginTest test_del

setKey test_del world
../shkv del test_del
if [ ! -f "${SHKV_STORE}/test_del" ]; then
    echo "SUCCESS"
else
    echo "FAIL"
    anyFail="true"
fi

endTest test_del


#
# list add
#
beginTest test_list_add

../shkv list add test_list_add item1
testKey test_list_add listAdd1.txt
../shkv list add test_list_add item2
testKey test_list_add listAdd2.txt

endTest test_list_add


#
# list del
#
beginTest test_list_del
cat ./dataset/listDel.txt > "${SHKV_STORE}/test_list_del"

../shkv list del test_list_del item2
testKey test_list_del listDel.txt
# item2item2 should not be destroyed by item2 del

endTest test_list_del


#
# list foreach
#
callback1 () {
    echo "callback1: $1"
    echo "callback1: $1" >> /tmp/shkv_foreach.txt
}
export -f callback1

beginTest test_list_foreach
cat ./dataset/listForeach.txt > "${SHKV_STORE}/test_list_foreach"

../shkv list foreach test_list_foreach callback1
cmpFile /tmp/shkv_foreach.txt ./check/foreach.txt

rm /tmp/shkv_foreach.txt 2> /dev/null
endTest test_list_foreach


#
# dict set
#
beginTest test_dict_set

../shkv dict set test_dict_set one oneword "comment of one"
../shkv dict set test_dict_set two twoword "comment of two"
testKey test_dict_set dictSet.txt

endTest test_dict_set


#
# dict get
#
beginTest test_dict_get
cat ./dataset/dict.txt > "${SHKV_STORE}/test_dict_get"

result=$(../shkv dict get test_dict_get two)
cmpResult "${result}" twoword

endTest test_dict_get


#
# dict props
#
beginTest test_dict_props
cat ./dataset/dict.txt > "${SHKV_STORE}/test_dict_props"

result=$(../shkv dict props test_dict_props)
cmpResult "${result}" "one=oneword two=twoword twotwo=twotwoword three=threeword"

endTest test_dict_props


#
# dict del
#
beginTest test_dict_del
cat ./dataset/dict.txt > "${SHKV_STORE}/test_dict_del"

../shkv dict del test_dict_del two
result=$(../shkv dict del test_dict_del two)
testKey test_dict_del dictDel.txt

endTest test_dict_del


echo ""
echo ""
[ "${anyFail}" = "true" ] && echo "TEST FAILED" || echo "TEST SUCCESS"
