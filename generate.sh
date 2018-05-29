#!/bin/bash

# Include the functions file
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]] ; then
    DIR="$PWD"
fi
. "$DIR/include/func.sh"

# Array stroring all values to be put into the output file,
# will be cleared on every item iteration
declare -A to_print

# Array storing all total values to be put into the output file,
# will be put on the end
declare -A to_print_protected

# Parse input arguments
src_file="$1/invoice.rtf" # RTF Invoice template
dst_file=$2 # RTF Invoice Output
var_file=$(readlink "$3")
var_file=$(echo "${var_file/../$PWD}") # Config file (absolute path)

# Table rows source files
itemrow="$1/item"
taxrow="$1/taxrate"

# Source file for invoice number
numbers_file="data/numbers"

# Number of items on the invoice
items=0

# 0 - parser is currently outside the item section in source data file
# 1 - parser is curreltly inside the item block in source data file
item_bool=0

# Arrays for tax-dependent total values
declare -A tax_whole_netto
declare -A tax_whole_tax
declare -A tax_whole_gross

# Get current date values
d=$(date '+%d')
m_long=$(date '+%m')
m=$(date '+%m')
y=$(date '+%Y')
today=$y"-"$m_long"-"$d

# Get invoice number (from environment variable)
nr=$(printf "%06d" "1")

# Create a new invoice file
cp "$src_file" "$dst_file"

# Count lines in the file containing variables
lines=$(wc -l < $3)

calculated=0

# Read each variable
for (( i=1; i <= $lines; i++ )) ; do
    # Get i-th line of a var_file
	line=$(sed -n ""$i"p" $var_file)

    # Write the previous set in an evaluated form to the separate file
    if [[ ! -z $var && ! -z $val ]] ; then
        echo "${var//\#}=$val" >> tempfile
    fi

    # Get variable name and its value (separated by '=' character)
	var=$(echo $line | cut -d'=' -f1)
	val=$(echo $line | cut -d'=' -f2)

    # Look for ordinal number marker
    if [[ $var == "ordinal_no" ]] ; then
        # Get ordinal number value
        source $numbers_file
        # Get ordinal number variable name
        pnt=$(echo "${val//\$}")
        # Prepare string for awk to use
        gawk_string="{FS=OFS=\"=\" }/"$pnt"/{\$2+=1}1"
        # Increment the value in file
        gawk -i inplace "$gawk_string" $numbers_file
        # Apply the value for the script
        val=$(eval echo $val)
        # Form valid invoice number
        nr=$(printf "$print" "$val")
        continue
    fi

    # Evaluate the variable, so the variables inside it will get defined
    val=$(eval echo $val)

    # Declare the variable itself, so it can be used by outside scripts
    if [[ $var != \#* ]] ; then
        printf -v $var "$val"
    fi

    # Remove \" marks from variables
    val=$(echo "${val//\"}")

    # Look for invoice number syntax
    if [[ $var == "print_no" ]] ; then
        print="%0"$val"d"
        continue
    fi

    # Check if current line is header (starts with '#')
	if [[ $var == \#* ]] ; then
        # Clear this line variable		
        val=""

        # Check if it's new item block
		if [[ $var == "#Item#" ]] ; then					
			
            # Switch boolean flags
            item_bool=1
            calculated=0

            # Clear variables that need to be calculated
            curr_item_tax_rate=""
            curr_item_quan=""
            curr_item_price_netto=""
			
			# If it's another item, print the current item array, flush it,
            # add new row in items table
			if [[ $items -ne 0 ]] ; then
                for K in "${!to_print[@]}"; do
                    replace "$K" "${to_print[$K]}" "$dst_file"
                done

                replaceWithFile "itemrowend" "$itemrow" "$dst_file"
                unset to_print
                declare -A to_print
			fi
			
			# Quantity of items on the invoice - increment
			((items++))

            # Insert an index number
            to_print["#item_no"]=$items
        
        # If it's meta file section
        elif [[ $var == "#Meta#" ]] ; then
            # Stop parsing it, this section is meant for the other script
            break
		fi

    # If it's not a header, check if both variable name and variable are not NULL
	elif [ -z "$var" ] || [ -z "$val" ]; then
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
        elif [[ "$var" == "service_date" ]]; then
            service_date=$val
        elif [[ "$var" == "deadline_date" ]]; then
            newval=$(./dateadd $service_date $val)
            val=$newval
        fi
        
        # Insert '#' at the beginning of variable name, so sed will find its position in dst_file
        var="#${var}"

        # If all needed data has been collected, perform pricing calculations for current item
        if [[ ! -z "$curr_item_tax_rate" ]] && [[ ! -z "$curr_item_quan" ]] && [[ ! -z "$curr_item_price_netto" ]] && [[ $calculated -eq 0 ]]; then
            # Calculate tax value for one piece of this item
            item_price_tax=$(floatMath "$curr_item_price_netto*$curr_item_tax_rate" 2) ### THIS VALUE WILL NOT BE PRINTED ###
            
            # Calculate gross price for one piece of this item
            to_print['#item_price_gross']=$(floatMath "$curr_item_price_netto+$item_price_tax" 2)

            # Calculate total netto price for all pieces of this item
            to_print['#whole_price_netto']=$(floatMath "$curr_item_price_netto*$curr_item_quan" 2)
            # Add total netto price of current item to the total netto of a respective tax rate
            tax_whole_netto[$curr_item_tax_rate]=$(addToArray "${tax_whole_netto[$curr_item_tax_rate]}" "${to_print['#whole_price_netto']}")

            # Calculate total tax for all pieces of this item
            whole_price_tax=$(floatMath "${to_print["#whole_price_netto"]}*$curr_item_tax_rate" 2) ### THIS VALUE WILL NOT BE PRINTED ###
            # Add total tax of current item to the total tax of a respective tax rate
            tax_whole_tax[$curr_item_tax_rate]=$(addToArray "${tax_whole_tax[$curr_item_tax_rate]}" "$whole_price_tax")

            # Calculate total gross price for all pieces of this item
            to_print["#whole_price_gross"]=$(floatMath "${to_print["#whole_price_netto"]}+$whole_price_tax" 2)
            # Add total gross price of current item to the total gross of a respective tax rate
            tax_whole_gross[$curr_item_tax_rate]=$(addToArray "${tax_whole_gross[$curr_item_tax_rate]}" "${to_print['#whole_price_gross']}")

            # Set a flag to 1, so values for this item won't be recalculated
            calculated=1
        fi
	fi

    # Add current replacement rule to the the respective array
    
    # Skip the header
    if [[ $var == *\# ]]; then
        continue
    elif [[ $item_bool -eq 0 ]]; then
        to_print_protected[$var]=$val
    else
        to_print[$var]=$val
    fi
done

# Print arrays
for K in "${!to_print_protected[@]}"; do
    echo "$K" "${to_print_protected[$K]}"
    replace "$K" "${to_print_protected[$K]}" "$dst_file"
done

for K in "${!to_print[@]}"; do
    echo "$K" "${to_print[$K]}"
    replace "$K" "${to_print[$K]}" "$dst_file"
done

tax_whole_netto_sum=0
tax_whole_tax_sum=0
tax_whole_gross_sum=0

# Print each tax-rate row (K - key)
j=1
for K in "${!tax_whole_netto[@]}"; do
    # Initialize or reset an array storing values to be printed in this tax rates row
    declare -A to_print_tax
    
    # Get value of tax rate, add it to an array as whole integer
    curr_tax_rate=$K
    to_print_tax["#tax_rate"]=$(floatMath "$curr_tax_rate*100" 0)

    curr_tax_whole_netto=${tax_whole_netto[$K]}
    tax_whole_netto_sum=$(addToArray "$tax_whole_netto_sum" "$curr_tax_whole_netto")
    to_print_tax["#tax_whole_netto"]=$curr_tax_whole_netto

    curr_tax_whole_tax=${tax_whole_tax[$K])}
    tax_whole_tax_sum=$(addToArray "$tax_whole_tax_sum" "$curr_tax_whole_tax")
    to_print_tax["#tax_whole_tax"]=$curr_tax_whole_tax

    curr_tax_whole_gross=${tax_whole_gross[$K]}
    tax_whole_gross_sum=$(addToArray "$tax_whole_gross_sum" "$curr_tax_whole_gross")
    to_print_tax["#tax_whole_gross"]=$curr_tax_whole_gross

    # Generate row, if it's another rate
    if [[ $j -ne 1 ]] ; then
        replaceWithFile "taxrowend" "$taxrow" "$dst_file"
    fi

    for L in "${!to_print_tax[@]}"; do
        echo "$L" "${to_print_tax[$L]}"
        replace "$L" "${to_print_tax[$L]}" "$dst_file"
    done
    ((j++))
done

# Print invoice totals
replace "#sum_tax_whole_netto" "$tax_whole_netto_sum" "$dst_file"
replace "#sum_tax_whole_tax" "$tax_whole_tax_sum" "$dst_file"
replace "#sum_tax_whole_gross" "$tax_whole_gross_sum" "$dst_file"
