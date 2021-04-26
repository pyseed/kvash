#!/bin/bash
program="kvash"
export KVASH_STORE="${HOME}/tmp/kvash"
#verbose=true

onBeforeIt () {
    rm "${KVASH_STORE}/$1" 2> /dev/null
}

onAfterIt () {
    rm "${KVASH_STORE}/$1" 2> /dev/null
}

. $(bashget get libash)/test.sh

# force key value
# setKey key value
setKey () {
    local key="$1"
    local value="$2"
    local filePath="${KVASH_STORE}/${key}"

    echo  -n "${value}" > "${filePath}"
}

# assertKeyFile expectedContentFilePath
assertKeyFile () {
    local expectedContentFilePath="$1"
    local filePath="${KVASH_STORE}/${current}"

    assertFile "${filePath}" "${expectedContentFilePath}"
}

# assertKeyValue expectedValue
assertKeyValue () {
    local expectedValue="$1"
    local filePath="${KVASH_STORE}/${current}"

    assertFileContent "${filePath}" "${expectedValue}"
}


listForeachCallback () {
    echo "listForeachCallback: $1"
    echo "listForeachCallback: $1" >> /tmp/${program}_listForeach.txt
}
export -f listForeachCallback

dictForeachCallback () {
    echo "dictForeachCallback: $1 $2"
    echo "dictForeachCallback: $1 $2" >> /tmp/${program}_dictForeach.txt
}
export -f dictForeachCallback


suiteGeneral () {
    local tmpFile

    suite "general"

    # ls
    it ls
    tmpFile=$(fixtureTmpFilePath)
    setKey one oneval
    setKey two twoval
    ../${program} ls > "${tmpFile}"
    assertFile "${tmpFile}" ./check/ls.txt
    rm "${tmpFile}"

    # ls search
    it ls_search
    tmpFile=$(fixtureTmpFilePath)
    ../${program} ls one > "${tmpFile}"
    assertFile "${tmpFile}" ./check/ls_search.txt
    rm "${KVASH_STORE}/one"
    rm "${KVASH_STORE}/two"
    rm "${tmpFile}"

    # touch
    it touch
    ../${program} touch "${current}"
    assertIsFile "${KVASH_STORE}/${current}"

    # touch (file exist)
    it touch_exist
    setKey "${current}" world
    ../${program} touch "${current}"
    assertKeyValue world

    # has not
    it has_not
    result=$(../${program} has "${current}")
    assertResult "${result}" "false"

    # has
    it has
    setKey "${current}" world
    result=$(../${program} has "${current}")
    assertResult "${result}" "true"

    # set1
    it set1
    ../${program} set "${current}" world
    assertKeyValue world

    # set2
    it set2
    ../${program} set "${current}" "world test"
    assertKeyValue "world test"

    # get
    it get
    setKey "${current}" world
    result=$(../${program} get "${current}")
    assertResult "${result}" world

    # path
    it path
    result=$(../${program} path "${current}")
    assertResult "${result}" "${KVASH_STORE}/${current}"

    # del
    it del
    setKey "${current}" world
    ../${program} del "${current}"
    assertIsNotFile "${KVASH_STORE}/${current}"
}

suiteAppend () {
    suite "append"

    # append from empty
    it append_from_empty
    ../${program} append "${current}" "append entry"
    assertKeyValue "append entry"

    # append
    it append
    setKey "${current}" world
    ../${program} "${current}" append "append entry"
    assertKeyValue "worldappend entry"

    # appendr from empty
    it appendr_from_empty
    ../${program} appendr "${current}" "appendr entry"
    assertKeyFile ./check/appendrFromEmpty.txt

    # appendr
    it appendr
    setKey "${current}" world
    ../${program} appendr "${current}" "appendr entry"
    assertKeyFile ./check/appendr.txt
}

suiteList () {
    local tmpFile

    suite "list"

    # add1
    it list_add1
    ../${program} list add "${current}" item1
    assertKeyFile ./check/listAdd1.txt

    # add2
    it list_add2
    setKey "${current}" item1
    echo "" >> "${KVASH_STORE}/${current}"
    ../${program} list add "${current}" item2
    assertKeyFile ./check/listAdd2.txt

    # del
    it list_del_single
    setKey "${current}" item
    ../${program} list del "${current}" item
    assertKeyFile ./check/listDelSingle.txt

    # del dataset n itms items
    it list_del_items
    cat ./dataset/listDel.txt > "${KVASH_STORE}/${current}"
    ../${program} list del "${current}" item2
    assertKeyFile ./check/listDelItems.txt
    # item2item2 should not be destroyed by item2 del

    # foreach
    it list_foreach
    cat ./dataset/list.txt > "${KVASH_STORE}/${current}"
    rm "/tmp/${program}_listForeach.txt" 2> /dev/null
    ../${program} list foreach "${current}" listForeachCallback
    assertFile "/tmp/${program}_listForeach.txt" ./check/listForeach.txt
    rm "/tmp/${program}_listForeach.txt"

    # sorted foreach
    it list_sforeach
    cat ./dataset/list.txt > "${KVASH_STORE}/${current}"
    rm "/tmp/${program}_listForeach.txt" 2> /dev/null
    ../${program} list sforeach "${current}" listForeachCallback
    assertFile "/tmp/${program}_listForeach.txt" ./check/listForeachSorted.txt
    rm "/tmp/${program}_listForeach.txt"
}

suiteDict () {
    suite "dict"

    # set
    it dict_set
    ../${program} dict set "${current}" one oneone
    ../${program} dict set "${current}" two twotwo
    ../${program} dict set "${current}" one oneword
    ../${program} dict set "${current}" two twoword
    assertKeyFile ./check/dictSet.txt
    # oneword and twoword should erase oneone twotwo

    # get
    it dict_get
    cat ./dataset/dict.txt > "${KVASH_STORE}/${current}"
    result=$(../${program} dict get "${current}" two)
    assertResult "${result}" twoword

    # props
    it dict_props
    cat ./dataset/dict.txt > "${KVASH_STORE}/${current}"
    result=$(../${program} dict props "${current}")
    assertResult "${result}" "one=oneword two=twoword twotwo=twotwoword three=threeword"

    # del
    it dict_del_single
    setKey "${current}" "hello=world"
    ../${program} dict del "${current}" hello
    assertKeyFile ./check/dictDelSingle.txt

    # del with n items dataset
    it dict_del_items
    cat ./dataset/dict.txt > "${KVASH_STORE}/${current}"
    ../${program} dict del "${current}" two
    assertKeyFile ./check/dictDelItems.txt
    # twotwo=twotwoword should not be destroyed by two del

    # foreach
    it dict_foreach
    cat ./dataset/dict.txt > "${KVASH_STORE}/${current}"
    rm "/tmp/${program}_dictForeach.txt" 2> /dev/null
    ../${program} dict foreach "${current}" dictForeachCallback
    assertFile "/tmp/${program}_dictForeach.txt" ./check/dictForeach.txt
    rm "/tmp/${program}_dictForeach.txt"
}


#
# BODY
#
suiteGeneral
suiteAppend
suiteList
suiteDict
report
