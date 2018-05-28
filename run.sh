#!/bin/bash

filelist=$(ls -d conf-enabled/*)
rtf_dir="templates/rtf"
mail_dir="templates/mail"
numbers_file=numbers

if [[ ${#filelist[@]} -eq 0 ]]; then
    printf "No activated scripts. Exiting\n"
    exit 1
fi

for V in "${filelist[@]}"; do
    source $numbers_file
    source $V
    filename="$buyer_name-$ordinal_no"
    target_dir="output/$buyer_name"
    mkdir -p "$target_dir"
    source generate.sh "$rtf_dir/$rtf_template" "output/$buyer_name/$filename.rtf" "$V"
    source tempfile
    /usr/share/Ted/examples/rtf2pdf.sh "output/$buyer_name/$filename.rtf" "output/$buyer_name/$filename.pdf"
    if [[ $1 != "--no-live" ]] ; then
        if [[ ! -z $mail_bcc ]] ; then
            mutt -e "set content_type=text/html" -s "$mail_subject" -b "$mail_bcc" "$mail_to" -a "$filename" < "$mail_dir/$mail_template"
        else
            mutt -e "set content_type=text/html" -s "$mail_subject" "$mail_to" -a "$filename" < "$mail_dir/$mail_template"
        fi
    fi
    rm "$target_dir/$filename.rtf"
    invoice_no=$(echo "${invoice_no//\/}")
    mv "$target_dir/$filename.pdf" "$target_dir/$invoice_no.pdf"
    rm tempfile
done