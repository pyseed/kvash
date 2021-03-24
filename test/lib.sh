#!/bin/bash

currentSuite=""
current=""
totalCount=0
successCount=0
failCount=0
lastResult=""
lastExpected=""

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
    # end of previous suite
    suiteEnd

    echo ""
    echo ""
    currentSuite="$*"
    declare -F onBeforeSuite &> /dev/null && onBeforeSuite "${currentSuite}"
}

suiteEnd () {
    # end previous test
    itEnd

    [ -n "${currentSuite}" ] && declare -F onAfterSuite &> /dev/null && onAfterSuite "${currentSuite}"
}

# a test is beginning
# will set current test name in "${current}"
# beginTest testName
it () {
    # end previous test
    itEnd

    current="$1"
    declare -F onBeforeIt &> /dev/null && onBeforeIt "${current}"
    ((totalCount=totalCount+1))
    echo ""
}

# a test has finished
# endTest
itEnd () {
    [ "${verbose}" = "true" ] && [ -n "${lastResult}" ] && (echo "${lastResult}"; echo "->"; echo "${lastExpected}")
    [ -n "${current}" ] && declare -F onAfterIt &> /dev/null && onAfterIt  "${current}"

    current=""
    lastResult=""
    lastExpected=""
}

# log a success
logSuccess () {
    echo -e "\e[32mOK\e[0m ${currentSuite}.${current}"
    ((successCount=successCount+1))
}

# log a fail
logFail () {
    echo -e "\e[31mKO\e[0m ${currentSuite}.${current}"
    ((failCount=failCount+1))
}

# get temporary file
getTmpFilePath () {
    local ts=$(date +"%T")
    echo "/tmp/test_${ts}.tmp"
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

export -f report
export -f suite
export -f it
export -f itEnd
export -f logSuccess
export -f logFail
export -f getTmpFilePath
export -f cmpFile
export -f cmpResult
