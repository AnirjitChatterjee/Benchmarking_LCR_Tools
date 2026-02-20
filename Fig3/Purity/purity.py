import os
import re
from collections import Counter

# Get all files ending with "_gf"
file_list = [f for f in os.listdir() if f.endswith("_gf")]

def process_fasta(file):
    output_file = file.replace("_gf", "_processed.txt")  # Naming output file
    with open(file, "r") as f, open(output_file, "w") as out_f:
        for line in f:
            if line.startswith(">"):
                # Extract protein name, start, and end positions from header
                match = re.match(r">(.+):(\d+)-(\d+)", line.strip())
                if match:
                    protein_name, start, end = match.groups()
            else:
                sequence = line.strip()
                # Find the most frequent character
                char_counts = Counter(sequence)
                most_common_char, most_common_count = char_counts.most_common(1)[0]
                # Calculate purity
                purity = most_common_count / len(sequence)
                # Write output
                out_f.write(f"{protein_name}\t{start}\t{end}\t{most_common_char}\t{purity:.4f}\n")

# Process each _gf file
for file in file_list:
    process_fasta(file)

print("Processing complete. Check the '_processed.txt' files.")

