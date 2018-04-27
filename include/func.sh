#!/bin/bash

# Replacing all occurences of $1 with $2 in file $3
function replace {
    # Check if file $3 contains at least one occurence of $1
    old_needle=$1
    haystack=$3
    
    grep -q "$old_needle" "$haystack"
    
    # If so, replace them
    if [ $? -eq 0 ] ; then
        new_needle=$(./utf <<< "$2")
        sed -i "s%$old_needle%$new_needle%" "$haystack"
    else # If not, print warning
        printf "WARNING: Did not find any occurences of \"$old_needle\" in \"$haystack\"\n"
    fi
}

# Replacing all occurences of $1 in file $3 with content of file $2
function replaceWithFile {
    # Check if file $3 contains at least one occurence of $1
    grep -q $1 $3

    # If so, replace them
    if [ $? -eq 0 ] ; then
        sed -i "/$1/ r $2" "$3"
    else # If not, print warning
        printf "WARNING: Did not find any occurences of \"$1\" file content in \"$3\"\n"
    fi
}

# Looks for instances of $1 in array pointed at $2 (example: searchArray "$a" "${array[@]}"
function searchArray {
    local e match="$1"
    shift
    
    # Return 0 if found a first instance
    for e; do [[ "$e" == "$match" ]] && return 0; done
    
    # Return 1 if went through the array without detecting any instances
    return 1;
}

function floatMath {
    # Default accuracy of rounding up is 2
    if [[ -z $2 ]] ; then
        acc=2
    else
        acc=$2
    fi

    # Print with leading zero
    res=$(bc <<< "scale=$acc; ($1)/1")

    if [[ $res == \.* ]] ; then
        echo "0""$res"
    else
        echo "$res"
    fi
}

function addToArray {
    if [[ $1 == "" ]] ; then
        echo $2
    else
        echo $(floatMath "$1+$2" $3)
    fi
}