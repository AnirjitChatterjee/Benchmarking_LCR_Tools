#!/bin/bash

# Input file
input="/home/ceglab5/Desktop/simulations/src/lcr_50/seg_s_res"

# Output file
output="/home/ceglab5/Desktop/simulations/src/lcr_50/seg_s_coords"

# Initialize variables
protein_name=""
start_pos=0
end_pos=0

# Process the input file
while IFS= read -r line; do
    if [[ $line == ">"* ]]; then
        # If the line starts with '>', extract the protein name
        protein_name=$(echo "$line" | awk '{print $1}')
    else
        # Extract the LCR sequence and positions
        if [[ $line =~ [a-z] ]]; then
            # Get the sequence part only
            sequence=$(echo "$line" | awk '{print $1}')
            # Get the position range
            positions=$(echo "$line" | awk '{print $2}')
            # Extract start and end positions
            start_pos=$(echo "$positions" | cut -d'-' -f1)
            end_pos=$(echo "$positions" | cut -d'-' -f2)
            # Write to the output file
            echo -e "${protein_name}\t${start_pos}\t${end_pos}" | awk 'NF==3' >> "$output"
        fi
    fi
done < "$input"


