#!/bin/bash

configure() {
    local PREFIX=$1
    local CONFIGURATION_FILE=$2
    readarray -t configuration < <(compgen  -A variable | grep "$PREFIX")
    for variable in "${configuration[@]}"
    do
      parameter="${variable//${PREFIX}/}"
      parameter="${parameter,,}"
      parameter="${parameter//_/\.}"
      eval value=\$$variable
      echo -e "\n$parameter=$value" >> $CONFIGURATION_FILE
    done
}
