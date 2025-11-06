import os
import pandas as pd

# Function to process each "_substrings.tsv" file
def process_substring_file(file_path):
    output_file = file_path.replace("_substrings.tsv", "_substring_counts.tsv")
    
    # Read the input file
    df = pd.read_csv(file_path, sep="\t")
    
    # Count occurrences of each unique substring
    substring_counts = df["Substring"].value_counts().reset_index()
    substring_counts.columns = ["Substring", "Count"]
    
    # Save the output to a new file
    substring_counts.to_csv(output_file, sep="\t", index=False)
    print(f"Processed: {file_path} -> {output_file}")

# Process all "_substrings.tsv" files in the current directory
for file in os.listdir():
    if file.endswith("_substrings.tsv"):
        process_substring_file(file)

print("Processing complete. Output files saved with '_substring_counts.tsv' suffix.")
