#!/bin/bash

filelist=$(ls -d conf-enabled/*)
rtf_dir="templates/rtf"
mail_dir="templates/mail"

if [[ ${#filelist[@]} -eq 0 ]]; then
    printf "No activated scripts. Exiting\n"
    exit 1
fi

for V in "${filelist[@]}"; do
    source $V
    filename="$buyer_name-$ordinal_no.rtf"
    source generate.sh "$rtf_dir/$rtf_template" "$filename" "$V"
    if [[ ! -z $mail_bcc ]] ; then
        mutt -s "$mail_subject" "$mail_to" -b "$mail_bcc" -a "$filename" < "$mail_dir/$mail_template"
    else
        mutt -s "$mail_subject" "$mail_to" -a "$filename" < "$mail_dir/$mail_template"
    fi
done