import os
import glob
import pandas as pd
from collections import Counter

def count_characters(input_file):
    # Read the input file
    df = pd.read_csv(input_file, sep='\t')
    
    # Concatenate all sequences into one string
    all_sequences = ''.join(df['Sequence'].dropna().astype(str))
    
    # Count occurrences of each unique character
    char_counts = Counter(all_sequences)
    total_chars = sum(char_counts.values())
    
    # Calculate proportions
    result = [(char, count, count / total_chars) for char, count in char_counts.items()]
    
    # Create an output file name
    output_file = input_file.replace("processed.tsv", "char_count.tsv")
    
    # Write the results to a new file
    with open(output_file, "w") as f:
        f.write("Character\tCount\tProportion\n")
        for char, count, proportion in sorted(result):
            f.write(f"{char}\t{count}\t{proportion:.6f}\n")
    
    print(f"Processed: {input_file} -> {output_file}")

# Process all files ending with "processed.tsv"
for file in glob.glob("*processed.tsv"):
    count_characters(file)

