#!/bin/bash

# Script To Write world to text file
# Author: Ridha Noomane

if [ $# -eq 2 ]; then
    writefile=$1
    writestr=$2
    if [[ -e "${writefile}" ]]; then
        rm -f $writefile
    else
        mkdir -p $(dirname $writefile) && touch $writefile
    fi
    echo $writestr > $writefile
else
    echo "Please enter two Argument file directory and string to write."
    echo "./write.sh [file directory] [string]"
    exit 1
fi