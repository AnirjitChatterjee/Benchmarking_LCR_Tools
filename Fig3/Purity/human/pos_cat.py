import os
import pandas as pd
import numpy as np

# Define bin edges and labels
bin_edges = np.arange(0, 1.1, 0.1)  # Bins: 0-0.1, 0.1-0.2, ..., 0.9-1.0
bin_labels = [f"{bin_edges[i]:.1f}-{bin_edges[i+1]:.1f}" for i in range(len(bin_edges) - 1)]

# Directory containing files
directory = "/home/anirjit/ANIRJIT/RESULTS/Purity/human"

# Get all .txt files in the directory
files = [f for f in os.listdir(directory) if f.endswith(".txt")]

for file in files:
    file_path = os.path.join(directory, file)
    
    # Check if file is empty before reading
    if os.path.getsize(file_path) == 0:
        print(f"Skipping {file} (Empty file)")
        continue
    
    try:
        # Read file (tab-separated)
        df = pd.read_csv(file_path, sep="\t", header=None, dtype=str)  # Read as string to avoid dtype issues
        
        # Check if file has at least 7 columns
        if df.shape[1] < 7:
            print(f"Skipping {file} (7th column missing)")
            continue
        
        # Convert the 7th column to numeric (handling errors)
        df.iloc[:, 6] = pd.to_numeric(df.iloc[:, 6], errors='coerce')

        # Drop NaN values (if conversion failed for any row)
        df = df.dropna(subset=[df.columns[6]])

        # Categorize values in the 7th column into bins
        df['Bin'] = pd.cut(df.iloc[:, 6], bins=bin_edges, labels=bin_labels, include_lowest=True)
        
        # Count occurrences in each bin
        bin_counts = df['Bin'].value_counts().reindex(bin_labels, fill_value=0)
        
        # Prepare output file
        output_file = os.path.join(directory, file.replace(".txt", "_bincounts.txt"))
        
        # Write to output file
        bin_counts.to_csv(output_file, sep="\t", header=["Count"], index_label="Bin")
        
        print(f"Processed: {file}, Output written to: {output_file}")

    except Exception as e:
        print(f"Error processing {file}: {e}")

print("Processing complete!")

