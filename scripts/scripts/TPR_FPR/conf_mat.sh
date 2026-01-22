#!/bin/bash

# Define directories
REAL_DIR="real"
TOOL_DIR="test"
OUTPUT_FILE="human_2_conf_mat.tsv"

# Write header to output file
echo -e "File1\tFile2\tTP\tFP\tFN\tTN" > "$OUTPUT_FILE"

# Iterate over all files in real/ and tool/
for file1 in "$REAL_DIR"/*; do
    for file2 in "$TOOL_DIR"/*; do
        # Compute TP, FP, FN, TN using bedtools and awk
        TP=$(bedtools intersect -a "$file1" -b "$file2" -wao | grep "LCR" | awk '{sum += $8} END {print sum}')
        FP=$(bedtools intersect -a "$file1" -b "$file2" -wao | grep -E "HCR|CBR" | awk '{sum += $8} END {print sum}')
        FN=$(bedtools subtract -a "$file1" -b "$file2" | grep "LCR" | awk '{print $3 - $2}' | awk '{sum += $1} END {print sum}')
        TN=$(bedtools subtract -a "$file1" -b "$file2" | grep -E "HCR|CBR" | awk '{print $3 - $2}' | awk '{sum += $1} END {print sum}')

        # Handle cases where no matches are found (set values to 0 if empty)
        TP=${TP:-0}
        FP=${FP:-0}
        FN=${FN:-0}
        TN=${TN:-0}

        # Append results to the output file
        echo -e "$(basename "$file1")\t$(basename "$file2")\t$TP\t$FP\t$FN\t$TN" >> "$OUTPUT_FILE"
    done
done

echo "Processing complete. Results saved to $OUTPUT_FILE."

