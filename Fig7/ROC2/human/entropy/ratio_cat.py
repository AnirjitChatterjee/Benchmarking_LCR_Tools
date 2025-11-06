# Script: categorize_by_entropy_ratio.py

input_file = "human_truth_ratio"
output_categories = {
    "0_0.2": [],
    "0.2_0.4": [],
    "0.4_0.6": [],
    "0.6_0.8": [],
    "0.8_1": []
}

# Read the input file
with open(input_file, "r") as infile:
    for line in infile:
        parts = line.strip().split()
        if len(parts) < 7 or parts[0] == "Protein":
            continue  # Skip header or malformed lines
        name = parts[0]
        try:
            ratio = float(parts[6])
        except ValueError:
            continue  # Skip lines with non-numeric ratio

        # Categorize based on ratio
        if 0 <= ratio <= 0.2:
            output_categories["0_0.2"].append(name)
        elif 0.2 < ratio <= 0.4:
            output_categories["0.2_0.4"].append(name)
        elif 0.4 < ratio <= 0.6:
            output_categories["0.4_0.6"].append(name)
        elif 0.6 < ratio <= 0.8:
            output_categories["0.6_0.8"].append(name)
        elif 0.8 < ratio <= 1.0:
            output_categories["0.8_1"].append(name)

# Write protein names into separate files
for category, proteins in output_categories.items():
    with open(f"proteins_{category}.txt", "w") as outfile:
        for protein in proteins:
            outfile.write(protein + "\n")

print("Categorization complete. Protein names saved in category-specific files.")

