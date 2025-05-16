#!/bin/bash

# Script Finder to find word in directory
# Author: Ridha Noomane

if [ $# -eq 2 ]; then
    filesdir=$1
    searchstr=$2

    if [[ -e "${filesdir}" ]]; then
        filenum=0
        findnum=0
        IFS=':'
        
        while read -r line; do
            filenum=$((filenum + 1))
            read -ra newarr <<< "$line"
            findnum=$((findnum + ${newarr[-1]}))
            # echo ${newarr[-1]}
        done <<< $(grep -rc ${filesdir} -e ${searchstr})
        echo "The number of files are ${filenum} and the number of matching lines are ${findnum}"
    else
        echo "${filesdir} not exist, Please specify correct directory"
        exit 1
    fi
else
    echo "Please enter 2 arguments file dir and Search String"
    exit 1
fi