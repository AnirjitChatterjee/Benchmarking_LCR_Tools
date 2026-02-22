import pandas as pd
import os
import glob

def resolve_overlaps(filename):
    # Read the input file
    df = pd.read_csv(filename, sep="\t")
    
    # Create a dictionary to store annotations per position
    position_annotations = {}
    
    for _, row in df.iterrows():
        protein = row['Protein_ID']
        start, end = row['Start'], row['End']
        classification = row['Classification']
        
        for pos in range(start, end + 1):
            key = (protein, pos)
            if key not in position_annotations:
                position_annotations[key] = set()
            position_annotations[key].add(classification)
    
    # Resolve conflicts
    resolved_annotations = {}
    for key, classifications in position_annotations.items():
        if 'LCR' in classifications:
            resolved_annotations[key] = 'LCR'
        elif 'CBR' in classifications:
            resolved_annotations[key] = 'CBR'
        else:
            resolved_annotations[key] = 'HCR'
    
    # Create new dataframe with resolved classifications
    new_rows = []
    for (protein, pos), classification in resolved_annotations.items():
        new_rows.append([protein, pos, classification])
    
    resolved_df = pd.DataFrame(new_rows, columns=['Protein_ID', 'Position', 'Classification'])
    resolved_df.to_csv(filename, sep="\t", index=False)
    print(f"File updated: {filename}")

# Process all files ending with "_classified"
for file in glob.glob("*_classified"):
    resolve_overlaps(file)

