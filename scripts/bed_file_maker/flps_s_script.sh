#!/bin/bash


for file in *_fLPS_strict_output.txt; 
do
  output_file="${file%.txt}_processed.bed"
  awk '{print $1, $4, $5, $2, $8, $6, $3, $7}' "$file" > "$output_file"
done

echo "Processing completed."

