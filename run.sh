#!/bin/bash

filelist=$(ls -d conf-enabled/*)

if [[ ${#filelist[@]} -eq 0 ]]; then
    printf "No activated scripts. Exiting\n"
    exit 1
fi

for V in "${filelist[@]}"; do
    source $V
    filename="$buyer_name $(date '+%y.%m.%d-%H:%M').rtf"
    ./generate.sh "$template" "$filename" "$V"
    mv "$filename" "$buyer_name-$ordinal_no"
done