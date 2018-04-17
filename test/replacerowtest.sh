#!/bin/bash

function replace {
    # Check if file $3 contains at least one occurence of $1
    grep -q $1 $3
    
    # If so, replace them
    if [ $? -eq 0 ] ; then
        sed -i "/$1/ r $2" "$3"
    else # If not, print warning
        printf "WARNING: Did not find any occurences of \"$1\" in \"$3\"\n"
    fi
}

itemrow=item
dst_file=wzortest.rtf
replace "itemrowend" $itemrow $dst_file
