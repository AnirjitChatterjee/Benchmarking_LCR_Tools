import os
import glob
import pandas as pd
import math

def shannon_entropy(sequence):
    """Calculate Shannon entropy of a sequence."""
    sequence = str(sequence)  # Ensure sequence is a string
    if not sequence:  # Handle empty or NaN values
        return 0  
    freq = {char: sequence.count(char) / len(sequence) for char in set(sequence)}
    return -sum(p * math.log2(p) for p in freq.values())

def purity(sequence):
    """Calculate the proportion of the most repeated character in the sequence."""
    sequence = str(sequence)  # Ensure sequence is a string
    if not sequence:  # Handle empty or NaN values
        return 0  
    return max(sequence.count(char) for char in set(sequence)) / len(sequence)

# Process all files ending with "_processed.tsv"
for file in glob.glob("*_processed.tsv"):
    df = pd.read_csv(file, sep="\t", dtype={"Sequence": str})  # Read as string

    # Drop rows where 'Sequence' is NaN
    df = df.dropna(subset=["Sequence"])

    # Compute entropy and purity
    df["Entropy"] = df["Sequence"].apply(shannon_entropy)
    df["Purity"] = df["Sequence"].apply(purity)

    # Save the output
    output_file = file.replace("_processed.tsv", "_entropy_purity.tsv")
    df.to_csv(output_file, sep="\t", index=False)
    print(f"Processed {file} -> {output_file}")

