#!/bin/bash
export SHKV_STORE="${HOME}/tmp/shkv"
#verbose=true

onBeforeIt () {
    rm "${SHKV_STORE}/$1" 2> /dev/null
}

onAfterIt () {
    rm "${SHKV_STORE}/$1" 2> /dev/null
}

wget -O libash_test.sh https://raw.githubusercontent.com/pyseed/libash/master/test.sh
. ./libash_test.sh

# force key value
# setKey key value
setKey () {
    local key="$1"
    local value="$2"
    local filePath="${SHKV_STORE}/${key}"

    echo  -n "${value}" > "${filePath}"
}

# assertKeyFile expectedContentFilePath
assertKeyFile () {
    local expectedContentFilePath="$1"
    local filePath="${SHKV_STORE}/${current}"

    assertFile "${filePath}" "${expectedContentFilePath}"
}

# assertKeyValue expectedValue
assertKeyValue () {
    local expectedValue="$1"
    local filePath="${SHKV_STORE}/${current}"

    assertFileContent "${filePath}" "${expectedValue}"
}


listForeachCallback () {
    echo "listForeachCallback: $1"
    echo "listForeachCallback: $1" >> /tmp/shkv_foreach.txt
}
export -f listForeachCallback


suiteGeneral () {
    suite "general"

    # set1
    it set1
    ../shkv set "${current}" world
    assertKeyValue world

    # set2
    it set2
    ../shkv set "${current}" "world test"
    assertKeyValue "world test"

    # get
    it get
    setKey "${current}" world
    result=$(../shkv get "${current}")
    assertResult "${result}" world

    # path
    it path
    result=$(../shkv path "${current}")
    assertResult "${result}" "${SHKV_STORE}/${current}"

    # del
    it del
    setKey "${current}" world
    ../shkv del "${current}"
    assertIsNotFile "${SHKV_STORE}/${current}"
}

suiteAppend () {
    suite "append"

    # append from empty
    it append_from_empty
    ../shkv append "${current}" "append entry"
    assertKeyValue "append entry"

    # append
    it append
    setKey "${current}" world
    ../shkv "${current}" append "append entry"
    assertKeyValue "worldappend entry"

    # appendr from empty
    it appendr_from_empty
    ../shkv appendr "${current}" "appendr entry"
    assertKeyFile ./check/appendrFromEmpty.txt

    # appendr
    it appendr
    setKey "${current}" world
    ../shkv appendr "${current}" "appendr entry"
    assertKeyFile ./check/appendr.txt
}

suiteList () {
    suite "list"

    # add1
    it list_add1
    ../shkv list add "${current}" item1
    assertKeyFile ./check/listAdd1.txt

    # add2
    it list_add2
    setKey "${current}" item1
    echo "" >> "${SHKV_STORE}/${current}"
    ../shkv list add "${current}" item2
    assertKeyFile ./check/listAdd2.txt

    # del
    it list_del
    cat ./dataset/listDel.txt > "${SHKV_STORE}/${current}"
    ../shkv list del "${current}" item2
    assertKeyFile ./check/listDel.txt
    # item2item2 should not be destroyed by item2 del

    # foreach
    it list_foreach
    cat ./dataset/listForeach.txt > "${SHKV_STORE}/${current}"
    ../shkv list foreach "${current}" listForeachCallback
    assertFile /tmp/shkv_foreach.txt ./check/foreach.txt
    rm /tmp/shkv_foreach.txt 2> /dev/null
}

suiteDict () {
    suite "dict"

    # set
    it dict_set
    ../shkv dict set "${current}" one oneword "comment of one"
    ../shkv dict set "${current}" two twoword "comment of two"
    assertKeyFile ./check/dictSet.txt

    # get
    it dict_get
    cat ./dataset/dict.txt > "${SHKV_STORE}/${current}"
    result=$(../shkv dict get "${current}" two)
    assertResult "${result}" twoword

    # props
    it dict_props
    cat ./dataset/dict.txt > "${SHKV_STORE}/${current}"
    result=$(../shkv dict props "${current}")
    assertResult "${result}" "one=oneword two=twoword twotwo=twotwoword three=threeword"

    # del
    it dict_del
    cat ./dataset/dict.txt > "${SHKV_STORE}/${current}"
    ../shkv dict del "${current}" two
    assertKeyFile ./check/dictDel.txt
    # twotwo=twotwoword should not be destroyed by two del
}


#
# BODY
#
suiteGeneral
suiteAppend
suiteList
suiteDict
report
