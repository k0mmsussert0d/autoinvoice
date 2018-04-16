#!/bin/bash

# Replacing all occurences of $1 with $2 in file $3
function replace {
    # Check if file $3 contains at least one occurence of $1
    grep -q $1 $3
    
    # If so, replace them
    if [ $? -eq 0 ] ; then
        sed -i "s%$1%$2%" "$3"
    else # If not, print warning
        printf "WARNING: Did not find any occurences of \"$1\" in \"$3\"\n"
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
