import os
import pandas as pd

# Function to process a single file
def filter_best_coverage(file_path):
    output_file = file_path.replace("_substrings.tsv", "_filtered.tsv")  # Output filename

    # Read the file
    df = pd.read_csv(file_path, sep="\t")

    # Select the highest coverage per row (excluding >1 values)
    def select_best(row):
        candidates = {
            "Mono": (row["Mono-peptide"], row["Mono-Coverage"]),
            "Di": (row["Di-peptide"], row["Di-Coverage"]),
            "Tri": (row["Tri-peptide"], row["Tri-Coverage"])
        }
        # Filter out coverage > 1 and sort by max coverage
        best_type, (best_peptide, best_coverage) = max(candidates.items(), key=lambda x: (x[1][1] if x[1][1] <= 1 else -1))

        return pd.Series([best_peptide, best_coverage])

    # Apply function to select best peptide
    df[["Best-Peptide", "Best-Coverage"]] = df.apply(select_best, axis=1)

    # Keep only relevant columns
    df_filtered = df[["Protein", "Start", "End", "Best-Peptide", "Best-Coverage"]]

    # Save the filtered output
    df_filtered.to_csv(output_file, sep="\t", index=False)
    print(f"Filtered file saved: {output_file}")

# Process all `_substrings.tsv` files
for file in os.listdir():
    if file.endswith("_substrings.tsv"):
        print(f"Processing: {file}")
        filter_best_coverage(file)

print("Filtering complete. New files saved with '_filtered.tsv' suffix.")

