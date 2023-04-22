#!/usr/bin/env bash
IFS=$'\n'
JS_FILE=$1
WASM_FILE=$2
REPLACE=$(wasm-opt -Oz --minify-imports-and-exports-and-modules $WASM_FILE -o $WASM_FILE | sort)
CODE=$(cat $JS_FILE)
for LINE in $REPLACE; do
  IFS=' => ' read -r -a TOKENS <<<"$LINE" 
  TA="${TOKENS[0]}"
  TB="${TOKENS[2]}"
  CODE=$(echo $CODE | sed "s/${TA}/${TB}/g")
  IFS=$'\n'
done
# For some reason, module "wbg" is renamed "a" in wasm code, but wasm-opt does not print mapping.
# Do it manually
CODE=$(echo $CODE | sed "s/wbg/a/g")
echo $CODE > $JS_FILE
