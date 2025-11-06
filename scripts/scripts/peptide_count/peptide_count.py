import os
import glob
import pandas as pd

def count_best_peptides(input_file, output_file):
    # Read the TSV file
    df = pd.read_csv(input_file, sep='\t')
    
    # Count occurrences of each unique Best-Peptide
    peptide_counts = df['Best-Peptide'].value_counts()
    
    # Save to a new file
    peptide_counts.to_csv(output_file, sep='\t', header=['Count'])

def process_files():
    # Get all filtered.tsv files in the current directory
    files = glob.glob("*filtered.tsv")
    
    for file in files:
        output_file = file.replace("filtered.tsv", "peptide_counts.tsv")
        count_best_peptides(file, output_file)
        print(f"Processed {file} -> {output_file}")

if __name__ == "__main__":
    process_files()

