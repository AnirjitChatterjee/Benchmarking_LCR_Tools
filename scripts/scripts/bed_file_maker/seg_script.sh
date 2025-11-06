#!/bin/bash

# Directory containing the input files
input_dir="/home/ceglab5/Desktop/SEG_output"

# Pattern to match the input files
pattern="*_seg_output.txt"

# Loop through all matching files
for input_file in $input_dir/$pattern; do
    # Get the base name of the input file without extension
    base_name=$(basename "$input_file" "_seg_output.txt")
   
    # Define the output file name
    output_file="${input_dir}/${base_name}_processed.bed"
   
    # Clear the output file if it already exists
    > "$output_file"
   
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
            if [[ $line =~ [a-zA-Z] ]]; then
                # Get the columns
                cols=($line)
                # Check if the line has at least 3 columns
                if [[ ${#cols[@]} -ge 3 ]]; then
                    sequence="${cols[0]}"
                    start_pos="${cols[1]}"
                    end_pos="${cols[2]}"
                    # Write to the output file
                    echo -e "${protein_name}\t${start_pos}\t${end_pos}" | awk 'NF==3' >> "$output_file"
                fi
            fi
        fi
    done < "$input_file"
   
    # Debug output
    echo "Processed $input_file, results saved to $output_file"
done
