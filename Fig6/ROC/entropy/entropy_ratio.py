import csv

# File paths (update if needed)
global_entropy_file = "human_entropy"
local_entropy_file = "human_truth_entropy"
output_file = "human_truth_ratio"

# Step 1: Load global entropy values into a dictionary
global_entropy = {}
with open(global_entropy_file, 'r') as f:
    reader = csv.DictReader(f, delimiter='\t')
    for row in reader:
        global_entropy[row["Protein"]] = float(row["Entropy"])

# Step 2: Process local segments and append new columns
with open(local_entropy_file, 'r') as f_in, open(output_file, 'w', newline='') as f_out:
    reader = csv.reader(f_in, delimiter='\t')
    writer = csv.writer(f_out, delimiter='\t')

    # Write header
    writer.writerow(["Protein", "Start", "End", "Sequence", "Local_Entropy", "Global_Entropy", "Ratio"])

    for row in reader:
        protein = row[0]
        local_entropy = float(row[4])

        if protein in global_entropy:
            global_ent = global_entropy[protein]
            ratio = local_entropy / global_ent if global_ent != 0 else 'NA'
            writer.writerow(row + [global_ent, ratio])

