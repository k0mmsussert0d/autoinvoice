#!/bin/bash

filelist=($(ls -d conf-enabled/*))
rtf_dir="templates/rtf"
mail_dir="templates/mail"
numbers_file_m="data/numbers_month"
numbers_file_y="data/numbers_year"
month_file="data/month"
year_file="data/year"

# Parsing run arguments
no_live=0
force=0

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --no-live)
    no_live=1
    shift
    ;;

    --force|-f)
    force=1
    shift
    ;;
esac
done

# Reset invoice numbers on a new month
old_month=$(cat $month_file)
today_month=$(date '+%m')
if [[ $old_month -ne $today_month ]] ; then
    sed -i 's%\([0-9]\+\)%1%' $numbers_file_m
fi
echo "$today_month" > $month_file

# Reset invoice numbers on a new year
old_year=$(cat $year_file)
today_year=$(date '+%Y')
if [[ $old_year -ne $today_year ]] ; then
    sed - i 's%\([0-9]\+\)%1%' $numbers_file_y
fi
echo "$today_year" > $year_file

# Exit, if conf-enabled dir is empty (no enabled scripts)
if [[ ${#filelist[@]} -eq 0 ]]; then
    printf "No activated scripts. Exiting\n"
    exit 1
fi

# Run generate.sh for each config
for V in "${filelist[@]}"; do
    # Run source files to get variables
    source $numbers_file_m
    source $numbers_file_y
    source $V

    # Check if it's invoicing date for this invoice
    today_day=$(date '+%-d')
    if [[ $today_day -ne $on_day ]] ; then
        # Generate invoice anyway in test environment
        if [[ $no_live -eq 1 ]] ; then
            printf "Generating a document on a wrong date, since --no-live option has been used\n"
        elif [[ $force -eq 1 ]] ; then
            printf "Sending a document on a wrong date, since --force option has been used\n"
        else
            exit 1
        fi
    fi

    # Set temporary filename
    filename="$buyer_name-$ordinal_no"
    target_dir="output/$buyer_name"
    mkdir -p "$target_dir"

    # Generate an invoice
    printf "Generating: from %s to %s using %s" "$rtf_template" "$filename.rtf" "$V"
    source generate.sh "$rtf_dir/$rtf_template" "output/$buyer_name/$filename.rtf" "$V"

    # Run new variables source file
    source tempfile

    # Convert invoice to PDF
    libreoffice --headless --invisible --norestore --convert-to pdf --outdir "$target_dir" "output/$buyer_name/$filename.rtf"

    # Send if not running in test environment
    if [[ $no_live -eq 0 || $force -eq 1 ]] ; then
        # With BCC if specified in config file
        if [[ ! -z $mail_bcc ]] ; then
            mutt -e "set content_type=text/html" -s "$mail_subject" -b "$mail_bcc" "$mail_to" -a "$target_dir/$filename.pdf" < "$mail_dir/$mail_template"
        else
            mutt -e "set content_type=text/html" -s "$mail_subject" "$mail_to" -a "$target_dir/$filename.pdf" < "$mail_dir/$mail_template"
        fi
    fi
    # Delete old RTF file
    rm "$target_dir/$filename.rtf"
    # Rename invoice file to just a number
    invoice_no=$(echo "$ordinal_no")
    # Move to a buyer directory
    mv "$target_dir/$filename.pdf" "$target_dir/$invoice_no.pdf"
    # Delete temporary variables file
    rm tempfile
done