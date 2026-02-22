import pandas as pd
import numpy as np

# Load the protein length file
input_file = "human_prot_length"  # Replace with actual filename
df = pd.read_csv(input_file, sep='\t', header=None, names=['Protein_ID', 'Length'])

# Sort proteins by length
df_sorted = df.sort_values(by='Length')

# Split into 10 equal groups
num_categories = 10
bins = np.array_split(df_sorted, num_categories)

# Write each category to a separate file
for i, bin_df in enumerate(bins, start=1):
    output_file = f"category_{i}.txt"
    bin_df.to_csv(output_file, sep='\t', index=False, header=False)
    print(f"Category {i} saved to {output_file}")

