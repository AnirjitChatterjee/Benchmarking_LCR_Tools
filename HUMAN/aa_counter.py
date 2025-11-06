import sys
import pandas as pd

def process_file(input_file, output_file):
    # Read the input file
    df = pd.read_csv(input_file, sep="\t")

    # Count occurrences of each character
    char_counts = df["Most_Repeated_Char"].value_counts().reset_index()
    char_counts.columns = ["Character", "Count"]

    # Calculate proportions
    total_count = char_counts["Count"].sum()
    char_counts["Proportion"] = char_counts["Count"] / total_count

    # Sort by character
    char_counts = char_counts.sort_values("Character")

    # Save to output file
    char_counts.to_csv(output_file, sep="\t", index=False)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py input.txt output.txt")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    process_file(input_file, output_file)

