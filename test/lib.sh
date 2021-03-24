#!/bin/bash

# beginTest testName will set current test name in "${current}"

tmpFile=/tmp/shkv_tmp.txt
anyFail=""
currentSuite=""
current=""
totalCount=0
successCount=0
failCount=0
lastResult=""
lastExpected=""

rm "${reportFile}" 2> /dev/null

# log a success
logSuccess () {
    echo -e "\e[32mOK\e[0m ${currentSuite}.${current}"

    ((successCount=successCount+1))
}

# log a fail
logFail () {
    anyFail="true"
    echo -e "\e[31mKO\e[0m ${currentSuite}.${current}"

    ((failCount=failCount+1))
}

# report
report () {
    echo ""
    echo "--"
    # no fails: success in gree
    [ ${failCount} != 0 ] && echo -e "success: ${successCount}" || echo -e "\e[32msuccess\e[0m: ${successCount}"
    # any fail: fails in red
    [ ${failCount} != 0 ] && echo -e "\e[31mfails\e[0m: ${failCount}"
    echo -e "total: ${totalCount}"
    echo ""
}

# suite
# suite name
suite () {
    # end previous test of previous suite
    itEnd

    currentSuite="$*"

    echo ""
    echo ""
}

# a test is beginning
# will set current test name in "${current}"
# beginTest testName
it () {
    # end previous test
    itEnd

    current="$1"
    rm "${SHKV_STORE}/${current}" 2> /dev/null

    ((totalCount=totalCount+1))
}

# a test has finished
# endTest
itEnd () {
    [ "${verbose}" = "true" ] && [ -n "${lastResult}" ] && (echo "${lastResult}"; echo "->"; echo "${lastExpected}")
    echo ""

    rm "${SHKV_STORE}/${current}" 2> /dev/null

    current=""
    lastResult=""
    lastExpected=""
}

# force key value
# setKey key value
setKey () {
    local key="$1"
    local value="$2"
    local filePath="${SHKV_STORE}/${key}"

    echo  -n "${value}" > "${filePath}"
}

# test key value, compare with file
# testKey expectedContentFilePath
testKeyFile () {
    local expectedContentFilePath="$1"
    local filePath="${SHKV_STORE}/${current}"

    cmpFile "${filePath}" "${expectedContentFilePath}"
}

# test key value, compare witj value
# testKeyValue expectedValue
testKeyValue () {
    local filePath="${SHKV_STORE}/${current}"

    echo  -n "$1" > "${tmpFile}"
    cmpFile "${filePath}" "${tmpFile}"
    rm "${tmpFile}"
}

# compare 2 files
# cmpFile result expected
cmpFile () {
    local result="$1"
    local expected="$2"

    if diff -u "${result}" "${expected}"; then
        logSuccess
    else
        logFail
    fi

    lastResult=$(cat "${result}" 2> /dev/null)
    lastExpected=$(cat "${expected}" 2> /dev/null)
}

# compare result
# cmpResult result expected
cmpResult () {
    local result="$1"
    local expected="$2"

    [ "${result}" = "${expected}" ] && logSuccess || logFail

    lastResult="${result}"
    lastExpected="${expected}"
}

export -f logSuccess
export -f logFail
export -f report
export -f suite
export -f it
export -f itEnd
export -f setKey
export -f testKeyFile
export -f testKeyValue
export -f cmpFile
export -f cmpResult
