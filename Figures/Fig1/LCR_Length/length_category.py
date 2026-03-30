import os
import pandas as pd
import glob

# Define categories
bins = [0, 10, 20, 50, 100, 200, float("inf")]
labels = ["0-10", "10-20", "20-50", "50-100", "100-200", "200+"]

# Get all files ending with '_lcr_length'
input_files = glob.glob("*_lcr_length")

for file in input_files:
    # Read the file
    df = pd.read_csv(file, sep="\t", header=None, names=["Protein", "Start", "End", "LCR_Length"])
    
    # Categorize LCR lengths
    df["Category"] = pd.cut(df["LCR_Length"], bins=bins, labels=labels, right=False)
    
    # Count occurrences per category
    category_counts = df["Category"].value_counts().reindex(labels, fill_value=0)
    
    # Save to new file
    output_file = file.replace("_lcr_length", "_categorized.tsv")
    category_counts.to_csv(output_file, sep="\t", header=["Count"], index_label="Category")
    
    print(f"Processed: {file} -> {output_file}")

