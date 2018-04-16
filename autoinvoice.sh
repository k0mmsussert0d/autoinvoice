#!/bin/bash

# Include the functions file
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]] ; then
    DIR="$PWD"
fi
. "$DIR/func"

# Source files
itemrow=rows/item
taxrow=rows/taxrate

# Parse input arguments
src_file=$1
dst_file=$2
var_file=$3

# Number of items on the invoice
items=0

# Array for tax rates, stored as whole integers (e.g. 23 for 23% taxation)
tax_rate_list=()

# Arrays for tax-dependent total values
tax_whole_netto=()
tax_whole_tax=()
tax_whole_gross=()

# Quantity of tax rates stores in tax_rate_list array
tax_rate_list_size=0

# Get current date values
d=$(date '+%d')
m=$(date '+%-m')
y=$(date '+%Y')

# Get invoice number (from environment variable)
nr=$(printf"%06d" "1")
: '
TODO:
    + register env variable for $nr generation
    + increment it after successful script execution
'

# Create a new invoice file
cp $src_file $dst_file

# Count lines in the file containing variables
lines=$(wc -l < $3)

# Read each variable
for (( i=1; i <= $lines; i++ )) ; do
    # Get i-th line of a var_file
	line=$(sed -n ""$i"p" $var_file)

    # Get variable name and its value (separated by '=' character)
	var=$(echo $line | cut -d'=' -f1)
	val=$(echo $line | cut -d'=' -f2)

    # Check if current line is header (starts with '[')
	if [[ $var == \[* ]] ; then
        # Clear this line variable		
        val=""

        # Check if it's for another item of an invoice
		if [[ $var == "[Item]" ]] ; then					
			# Go to the next line
			((i++))
			
			# If it's another item, add new row in items table and clear variables
			if [[ $items -ne 0 ]] ; then
                replaceWithFile "itemrowend" $itemrow $dst_file
                curr_item_tax_rate=""
                curr_item_quan=""
                curr_item_price_netto=""
			fi
			
			# Quantity of items on the invoice - increment
			((items++))
		fi

    # If it's not a header, check if both variable name and variable are not NULL
	elif [ -z "$var" ] || [ -z "$val" ] ; then
		printf "Error. Insufficent arguments on line %d\n" "$i"
		exit 1

    # If it goes here, it means we have valid variable line, perform an insertion
	else
        # Look for a line with taxation rate
		if [[ "$var" == "item_tax_rate" ]]; then
            curr_item_tax_rate=$val
            
            # Search for it in array
            searchArray "$curr_item_tax_rate" "${tax_rate_list[@]}"
                
            # If it hasn't been mentioned yet, add it to the array
            if [[ $? -eq 1 ]]
                tax_rate_list+=($val)
            fi
        elif [[ "$var" == "item_quan" ]]; then
            curr_item_quan=$val
        elif [[ "$var" == "item_price_netto" ]]; then
            curr_item_price_netto=$val
        fi
        
        # Insert '#' at the beginning of variable name, so sed will find its position in dst_file
        var="#${var}"

        # Replace all occurreneces of $var with $val
        replace $var $val $dst_file
        
        # If all needed data has been collected, calculate total price for the current item(s)
        if [[ ! -z "$curr_item_tax_rate" ]] && [[ ! -z "$curr_item_quan" ]] && [[ ! -z "$curr_item_price_netto" ]]; then
            # Calculate tax to be paid for this item
            to_add=$curr_item_tax_rate*$curr_item_quan*$curr_item_price_netto
            
            # Add it to the total tax to be paid
            if [[ -z $tax_whole_tax[ items ] ]]; then
                tax_whole_tax[ items ]=$to_add
            else
                ((tax_whole_tax[ items ]+=$to_add))
            fi
        fi
	fi
done

for (( i=1; i <= ${#tax_rate_list[@]} )) ; do
    # If it's not a first tax rate, add a row for it
    if [[ $i -ne 1 ]] ; then
        replaceWithFile "taxrowend" $taxrow $dst_file
    fi

    
done

# sed -i "s/"#invoice_no"/"FV123456"/" $dst_file

