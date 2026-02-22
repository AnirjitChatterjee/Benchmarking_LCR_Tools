#!/bin/bash


for file in *_fLPS_strict_output.txt; 
do
  output_file="${file%.txt}_processed.bed"
  awk '{print $1, $5, $6, $7, $3, $9, $2, $4, $8, $10, $11, $12}' "$file" > "$output_file"
done

echo "Processing completed."

