# kvash

lite file based key value store in bash

## getting started

```
wget -O libash_test.sh https://raw.githubusercontent.com/pyseed/kvash/master/kvash.sh
./kvash help
```

## scope

- each key is a file, so do not use this tool as a massive storage (you do not want millions of ionodes isn't it ?)
- the goal is not to replace or mimic a 'true' key value storage
- the goal is to store embedded state when a 'true' key value storage seems overkill
- this tool helps to have list and dict types for your states in bash

## types

- string: set/get
- list: list commands
- dict: dict commands, dicts can be exported as env variables

## commands

location of your store (main directory path) should be set in KVASH_STORE environment variable:

```bash
export KVASH_STORE="${HOME}/kvstore/store1"
```

there is no explicit "clear" command, please use `rm "${KVASH_STORE}/*"` to delete all the store (all the keys) 

### list keys

kvash ls [search]

```bash
kvash ls
> foo
> bar
> foobar
```

```bash
kvash ls foo
> foo
> foobar
```

```bash
kvash ls bar
> bar
> foobar
```

### touch key

kvash touch key

will not erase content if exists

### set value (and string)

kvash set key value

### append

kvash append key value

please do not add content to a list/dict key until you know what you do

### append with crlf after value

kvash appendr key value

please do not add content to a list/dict key until you know what you do

### get key full path

kvash path key

```bash
kvash path key
> /path/to/key
```

### remove key

kvash del key

that will delete related key file

### list - add item

kvash list add key item


### list - delete item

kvash list del key

no duplicates expected in your use case ? before list add you can always call list del

### list - foreach

kvash list foreach key callback

item is passed as $1 in callback

```bash
callback () {
  echo "from callback, item: $1"
}
export -f callback

kvash list foreach key callback
```

### dict - set prop

kvash dict set key prop value [comment]

### dict - get prop value

kvash dict get key prop

```bash
kvash dict get key prop
> propValue

export prop=$(kvash dict get key prop)
```

### dict - get props as args

kvash dict props key

```bash
kvash dict props key
> foo=Foo bar=Bar

export $(kvash dict props key)
```

### dict - del prop

kvash dict del key prop

## development

### unit test

```
cd test
./test.sh
```
