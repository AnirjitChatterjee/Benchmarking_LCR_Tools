import os
import pandas as pd
import glob

# Define categories
categories = {
    "0-20": (0, 20),
    "20-40": (20, 40),
    "40-60": (40, 60),
    "60-80": (60, 80),
    "80-100": (80, 100)
}

# Get all files ending with "_percov"
input_files = glob.glob("*_percov")

for file in input_files:
    # Read the file
    df = pd.read_csv(file, sep="\t", header=0, names=["Protein", "LCR_Coverage_Percentage"])
    
    # Initialize category counts
    category_counts = {key: 0 for key in categories.keys()}
    
    # Categorize values
    for value in df["LCR_Coverage_Percentage"]:
        for category, (low, high) in categories.items():
            if low <= value < high:
                category_counts[category] += 1
                break

    # Convert to DataFrame for output
    output_df = pd.DataFrame(list(category_counts.items()), columns=["Category", "Count"])
    
    # Define output filename
    output_filename = file.replace("_percov", "_percov_categorized.tsv")
    
    # Save output
    output_df.to_csv(output_filename, sep="\t", index=False)

    print(f"Processed: {file} -> {output_filename}")

