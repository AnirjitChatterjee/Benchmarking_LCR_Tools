#!/bin/bash

# Detect all BED files ending with "_sorted.bed" in the current directory
BED_FILES=(*_sorted.bed)

# Output matrix file
MATRIX_FILE="jaccard_matrix.tsv"

# Number of BED files detected
NUM_FILES=${#BED_FILES[@]}

# Check if there are at least 2 BED files
if [ "$NUM_FILES" -lt 2 ]; then
    echo "Error: Less than 2 BED files found. Ensure at least two *_sorted.bed files exist."
    exit 1
fi

# Create the header row
echo -ne "File\t" > "$MATRIX_FILE"
echo -e "$(printf "%s\t" "${BED_FILES[@]}" | sed 's/\t$//')" >> "$MATRIX_FILE"

# Initialize an empty matrix
declare -A JACCARD_MATRIX

# Compute pairwise Jaccard indices
for ((i=0; i<NUM_FILES; i++)); do
    FILE1="${BED_FILES[i]}"
   
    # Start row with file name
    echo -ne "$FILE1\t" >> "$MATRIX_FILE"
   
    for ((j=0; j<NUM_FILES; j++)); do
        FILE2="${BED_FILES[j]}"
       
        if [ "$i" -eq "$j" ]; then
            JACCARD_MATRIX["$i,$j"]=1.000  # Self-comparison is always 1
        elif [ "$j" -lt "$i" ]; then
            JACCARD_MATRIX["$i,$j"]=${JACCARD_MATRIX["$j,$i"]}  # Use symmetry
        else
            # Compute Jaccard index if not already calculated
            JACCARD_VALUE=$(bedtools jaccard -a "$FILE1" -b "$FILE2" | tail -n1 | awk '{print $3}')
            JACCARD_MATRIX["$i,$j"]=$JACCARD_VALUE
        fi
       
        # Append value to the row
        echo -ne "${JACCARD_MATRIX["$i,$j"]}\t" >> "$MATRIX_FILE"
    done
   
    echo "" >> "$MATRIX_FILE"  # New line for the next row
done

echo "Jaccard matrix saved in $MATRIX_FILE"
