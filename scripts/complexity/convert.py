import sys
import pandas as pd
import glob
import os

# Find all input files ending with "_classified"
input_files = glob.glob("*_classified")

for input_file in input_files:
    output_file = input_file.replace("_classified", "_real.bed")

    # Load input file
    df = pd.read_csv(input_file, sep='\t')

    # Ignore Position 0 and start from Position 1
    df = df[df['Position'] > 0]

    # Maintain the original order of Protein_ID
    df['Protein_ID'] = pd.Categorical(df['Protein_ID'], categories=df['Protein_ID'].unique(), ordered=True)

    def find_contiguous_regions(df):
        results = []
        for protein, group in df.groupby('Protein_ID', sort=False, observed=False):  # Suppress FutureWarning
            start = None
            current_class = None
            for i, row in group.iterrows():
                pos, classification = row['Position'], row['Classification']
                if start is None:
                    start = pos
                    current_class = classification
                elif classification != current_class:
                    results.append([protein, start, prev_pos, current_class])
                    start = pos
                    current_class = classification
                prev_pos = pos
            results.append([protein, start, prev_pos, current_class])
        return results

    # Process the data
    regions = find_contiguous_regions(df)

    # Convert to DataFrame and save
    output_df = pd.DataFrame(regions, columns=['Protein_ID', 'Start_Position', 'End_Position', 'Classification'])
    output_df.to_csv(output_file, sep='\t', index=False)

    print(f"Processed: {input_file} -> {output_file}")

