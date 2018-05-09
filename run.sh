#!/bin/bash

filelist=$(ls -d conf-enabled/*)

if [[ ${#filelist[@]} -eq 0 ]]; then
    printf "No activated scripts. Exiting\n"
    exit 1
fi

for V in "${filelist[@]}"; do
    source $V
    filename="$buyer_name-$ordinal_no.rtf"
    source generate.sh "$template" "$filename" "$V"
    mutt -s "$mail_subject" "$mail_to" -a "$filename" < "$mail_content"
done