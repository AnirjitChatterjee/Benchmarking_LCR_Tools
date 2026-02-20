import os
import pandas as pd

# Get all files ending with "_sorted.bed"
file_list = sorted([f for f in os.listdir() if f.endswith("_sorted.bed")])  # Sort files alphabetically
output_file = "entity_counts.tsv"

counts = []

for file in file_list:
    if os.stat(file).st_size == 0:  # Skip empty files
        print(f"Skipping empty file: {file}")
        continue

    try:
        df = pd.read_csv(file, sep="\t", header=None)  # Read file
        unique_entities = df[0].nunique()  # Count unique values in the first column
        counts.append([file, unique_entities])
    except Exception as e:
        print(f"Error processing {file}: {e}")  # Print error message and continue

# Write to a TSV file only if there is valid data
if counts:
    df_counts = pd.DataFrame(counts, columns=["Filename", "Entity_Count"])
    df_counts = df_counts.sort_values(by="Filename")  # Sort output alphabetically
    df_counts.to_csv(output_file, sep="\t", index=False)
    print(f"Entity counts saved to {output_file}")
else:
    print("No valid data found in files. No output generated.")

