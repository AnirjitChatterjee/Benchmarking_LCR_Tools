import pandas as pd
import glob

# Read the protein length file into a dictionary
length_file = "human_prot_length"  # Replace with the actual filename
length_df = pd.read_csv(length_file, sep="\t", header=None, names=["Protein", "Length"])
protein_lengths = dict(zip(length_df["Protein"], length_df["Length"]))

# Process all _processed.txt files
files = glob.glob("*.txt")

for file in files:
    df = pd.read_csv(file, sep="\t", header=None, names=["Protein", "Start", "End", "Residue", "Value"])
    
    # Add the corresponding protein length
    df["Protein_Length"] = df["Protein"].map(protein_lengths)
    
    # Write back to the same file
    df.to_csv(file, sep="\t", index=False, header=False)

print("Files updated successfully!")

