#!/bin/bash

# Define the input directory containing the BED files
input_directory="/home/ceglab5/Desktop/RESULTS/HUMAN"

# Define the output directory where results will be saved
output_directory="/home/ceglab5/Desktop/RESULTS/HUMAN"

# Loop through each BED file in the input directory
for input_file in "$input_directory"/*.bed; do
    # Extract the base filename without the path
    base_filename=$(basename "$input_file")
   
    # Define the output filename
    output_file="$output_directory/${base_filename%}_sorted"
   
    # Run the bedtools intersect command and save the output
    sort -k 1,1 -k2,2n "$input_file" | awk '{ if ($1 !~ /^[0-9]+$/) print }' > "$output_file"
   
    # Optionally, print a message indicating that the file has been processed
    echo "Processed $input_file -> $output_file"
done

