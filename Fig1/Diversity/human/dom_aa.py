import os
import glob
import pandas as pd
from collections import Counter

def find_most_repeated_char(sequence):
    if not sequence:
        return ""
    return Counter(sequence).most_common(1)[0][0]

def process_file(input_file, output_file):
    # Read the TSV file
    df = pd.read_csv(input_file, sep='\t')
    
    # Find most repeated character in each sequence
    df['Most_Repeated_Char'] = df['Sequence'].apply(find_most_repeated_char)
    
    # Save to a new file
    df.to_csv(output_file, sep='\t', index=False)

def process_files():
    # Get all _sns files in the current directory
    files = glob.glob("*_sns")
    
    for file in files:
        output_file = file + "_aa"
        process_file(file, output_file)
        print(f"Processed {file} -> {output_file}")

if __name__ == "__main__":
    process_files()

