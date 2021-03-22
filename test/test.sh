#!/bin/bash
export SHKV_STORE="${HOME}/tmp/shkv"
#verbose=true

# lib.sh.beginTest will set current test name in "${current}"
. lib.sh

listForeachCallback () {
    echo "listForeachCallback: $1"
    echo "listForeachCallback: $1" >> /tmp/shkv_foreach.txt
}
export -f listForeachCallback

serie () {
    #
    # set1
    #
    beginTest set1

    ../shkv set "${current}" world
    testKeyValue world

    endTest


    #
    # set2
    #
    beginTest set2

    ../shkv set "${current}" "world test"
    testKeyValue "world test"

    endTest


    #
    # get
    #
    beginTest get

    setKey "${current}" world
    result=$(../shkv get "${current}")
    cmpResult "${result}" world

    endTest


    #
    # path
    #
    beginTest path

    result=$(../shkv path "${current}")
    cmpResult "${result}" "${SHKV_STORE}/${current}"

    endTest


    #
    # del
    #
    beginTest del

    setKey "${current}" world
    ../shkv del "${current}"
    [ -f "${SHKV_STORE}/${current}" ] && logFail || logSuccess

    endTest
}

serieAppend () {
    #
    # append from empty
    #
    beginTest append_from_empty

    ../shkv append "${current}" "append entry"
    testKeyValue "append entry"

    endTest


    #
    # append
    #
    beginTest append

    setKey "${current}" world
    ../shkv "${current}" append "append entry"
    testKeyValue "worldappend entry"

    endTest


    #
    # appendr from empty
    #
    beginTest appendr_from_empty

    ../shkv appendr "${current}" "appendr entry"
    testKeyFile ./check/appendrFromEmpty.txt

    endTest


    #
    # appendr
    #
    beginTest appendr

    setKey "${current}" world
    ../shkv appendr "${current}" "appendr entry"
    testKeyFile ./check/appendr.txt

    endTest
}

serieList () {
    #
    # add1
    #
    beginTest list_add1

    ../shkv list add "${current}" item1
    testKeyFile ./check/listAdd1.txt

    endTest


    #
    # add2
    #
    beginTest list_add2

    setKey "${current}" item1
    echo "" >> "${SHKV_STORE}/${current}"
    ../shkv list add "${current}" item2
    testKeyFile ./check/listAdd2.txt

    endTest


    #
    # del
    #
    beginTest list_del
    cat ./dataset/listDel.txt > "${SHKV_STORE}/${current}"

    ../shkv list del "${current}" item2
    testKeyFile ./check/listDel.txt
    # item2item2 should not be destroyed by item2 del

    endTest



    #
    # foreach
    #
    beginTest list_foreach
    cat ./dataset/listForeach.txt > "${SHKV_STORE}/${current}"

    ../shkv list foreach "${current}" listForeachCallback
    cmpFile /tmp/shkv_foreach.txt ./check/foreach.txt

    rm /tmp/shkv_foreach.txt 2> /dev/null
    endTest
}

serieDict () {
    #
    # set
    #
    beginTest dict_set

    ../shkv dict set "${current}" one oneword "comment of one"
    ../shkv dict set "${current}" two twoword "comment of two"
    testKeyFile ./check/dictSet.txt

    endTest


    #
    # get
    #
    beginTest dict_get
    cat ./dataset/dict.txt > "${SHKV_STORE}/${current}"

    result=$(../shkv dict get "${current}" two)
    cmpResult "${result}" twoword

    endTest


    #
    # props
    #
    beginTest dict_props
    cat ./dataset/dict.txt > "${SHKV_STORE}/${current}"

    result=$(../shkv dict props "${current}")
    cmpResult "${result}" "one=oneword two=twoword twotwo=twotwoword three=threeword"

    endTest


    #
    # del
    #
    beginTest dict_del
    cat ./dataset/dict.txt > "${SHKV_STORE}/${current}"

    ../shkv dict del "${current}" two
    testKeyFile ./check/dictDel.txt
    # twotwo=twotwoword should not be destroyed by two del

    endTest
}


#
# BODY
#
main () {
    serie
    serieAppend
    serieList
    serieDict

    report
}

main
