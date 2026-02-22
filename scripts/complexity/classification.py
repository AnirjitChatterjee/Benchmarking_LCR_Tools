import os
import glob
import pandas as pd

def classify_region(most_freq_aa_percent, mutation_percent):
    if most_freq_aa_percent < 50 and mutation_percent <= 50:
        return "CBR"
    elif most_freq_aa_percent >= 50 and mutation_percent <= 50:
        return "LCR"
    elif most_freq_aa_percent < 50 and mutation_percent > 50:
        return "HCR"
    else:
        return "Unknown"  # Should not occur based on the given criteria

def process_file(file_path):
    output_file = file_path.replace("_out", "_classified")
    df = pd.read_csv(file_path, sep="\t")
    
    # Apply classification
    df["Classification"] = df.apply(lambda row: classify_region(row["Most_Frequent_AA_Percent"], row["Mutation_Percent"]), axis=1)
    
    # Select relevant columns
    df_output = df[["Protein_ID", "Start", "End", "Most_Frequent_AA_Percent", "Mutation_Percent", "Classification"]]
    
    # Save output
    df_output.to_csv(output_file, sep="\t", index=False)
    print(f"Processed: {file_path} -> {output_file}")

if __name__ == "__main__":
    input_files = glob.glob("*_out")  # Find all files ending with _mw_out
    for file in input_files:
        process_file(file)

