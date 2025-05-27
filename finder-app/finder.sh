#!/bin/sh
# Script: Finder
# Description: Search for a word recursively in files under a directory
# Author: Ridha Noomane
if [ "$#" -ne 2 ]; then
   echo "Usage: $0 <directory> <search_string>"
   exit 1
fi
filesdir=$1
searchstr=$2
if [ ! -d "$filesdir" ]; then
   echo "Error: '$filesdir' is not a valid directory"
   exit 1
fi
# Initialize counters
filenum=0
match_count=0
# Loop over all regular files
for file in $(find "$filesdir" -type f); do
   count=$(grep -o "$searchstr" "$file" 2>/dev/null | wc -l)
   if [ "$count" -gt 0 ]; then
       match_count=$((match_count + count))
       filenum=$((filenum + 1))
   fi
done
echo "The number of files are ${filenum} and the number of matching lines are ${match_count}"