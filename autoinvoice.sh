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

# Arrays for tax-dependent total values
declare -A tax_whole_netto
declare -A tax_whole_tax
declare -A tax_whole_gross

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
             # Convert percentage to fraction (e.g. 23 --> 0.23)
            curr_item_tax_rate=$(floatMath "$val*0.01" 2)

        # Look for item quantity
        elif [[ "$var" == "item_quan" ]]; then
            curr_item_quan=$val

         # Look for item netto price
        elif [[ "$var" == "item_price_netto" ]]; then
            curr_item_price_netto=$val
        fi
        
        # Insert '#' at the beginning of variable name, so sed will find its position in dst_file
        var="#${var}"

        # Replace all occurreneces of $var with $val
        replace $var $val $dst_file
        
        # If all needed data has been collected, perform pricing calculations for current item
        if [[ ! -z "$curr_item_tax_rate" ]] && [[ ! -z "$curr_item_quan" ]] && [[ ! -z "$curr_item_price_netto" ]]; then
            # Calculate tax for one piece of this item
            item_price_tax=$(floatMath "$curr_item_price_netto*$curr_item_tax_rate" 2)
            
            # Calculate gross price for one piece of this item
            item_price_gross=$(floatMath "$curr_item_price_netto+$item_price_tax" 2)

            # Calculate total netto price for all pieces of this item
            whole_price_netto=$(floatMath "$curr_item_price_netto*$curr_item_quan" 2)
            # Add total netto price of current item to the total netto of a respective tax rate
            tax_whole_netto[$curr_item_tax_rate]=$(floatMath "${tax_whole_netto[$curr_item_tax_rate]}+$whole_price_netto")

            # Calculate total tax for all pieces of this item
            whole_price_tax=$(floatMath "$whole_price_netto*$curr_item_tax_rate" 2)
            # Add total tax of current item to the total tax of a respective tax rate
            tax_whole_tax[$curr_item_tax_rate]=$(floatMath "${tax_whole_tax[$curr_item_tax_rate]}+$whole_price_tax")

            # Calculate total gross price for all pieces of this item
            whole_price_gross=$(floatMath "$whole_price_netto+$whole_price_tax" 2)
            # Add total gross price of current item to the total gross of a respective tax rate
            tax_whole_gross[$curr_item_tax_rate]=$(floatMath "${tax_whole_gross[$curr_item_tax_rate]}+$whole_price_gross")
        fi
	fi
done

# Get an amount of rates based on tax array length
rates=${#tax_whole_netto[@])}

tax_whole_netto_sum=0
tax_whole_tax_sum=0
tax_whole_gross_sum=0

# Print each tax-rate row (K - key)
for K in "${!tax_whole_netto[@]}"; do
    # Get values for this key and add each value to the respective sum
    curr_tax_rate=$K

    curr_tax_whole_netto=${tax_whole_netto[$K]}
    tax_whole_netto_sum=$(floatMath "$curr_tax_whole_netto+$tax_whole_netto_sum" 2)

    curr_tax_whole_tax=${tax_whole_tax[$K])}
    tax_whole_tax_sum=$(floatMath "$curr_tax_whole_tax+$tax_whole_tax_sum" 2)

    curr_tax_whole_gross=${tax_whole_gross[$K]}
    tax_whole_gross_sum=$(floatMath "$curr_tax_whole_gross+$tax_whole_gross_sum" 2)

    # Generate row, if it's another rate
    if [[ $i -ne 1 ]] ; then
        replaceWithFile "taxrowend" $taxrow $dst_file
    fi

    # Insert sums for current rate
    replace "#tax_rate" $curr_tax_rate $dst_file
    replace "#tax_whole_netto" $curr_tax_whole_netto $dst_file
    replace "#tax_whole_tax" $curr_tax_whole_tax $dst_file
    replace "#tax_whole_gross" $curr_tax_whole_gross        
done

# Inserts sums for all tax rates
replace "#tax_whole_netto_sum" $tax_whole_netto_sum
replace "#tax_whole_tax_sum" $tax_whole_tax_sum
replace "#tax_whole_gross_sum" $tax_whole_gross_sum
