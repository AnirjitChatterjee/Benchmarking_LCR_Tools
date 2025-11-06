import os
import re
from collections import Counter

# Function to find the most frequent substring for a given length
def find_most_frequent_substring(sequence, length):
    substr_counts = Counter(sequence[i:i + length] for i in range(len(sequence) - length + 1))
    most_common = substr_counts.most_common(1)
    return most_common[0] if most_common else ("-", 0)

# Function to process a single FASTA file
def process_fasta_file(file_path):
    output_file = file_path + "_substrings.tsv"

    with open(file_path, "r") as infile, open(output_file, "w") as outfile:
        outfile.write("Protein\tStart\tEnd\tMono-peptide\tMono-Coverage\tDi-peptide\tDi-Coverage\tTri-peptide\tTri-Coverage\n")  # Header
        
        sequence = ""
        header = ""

        for line in infile:
            line = line.strip()
            if line.startswith(">"):
                # Process the previous sequence
                if sequence and header:
                    match = re.match(r">(.+):(\d+)-(\d+)", header)
                    if match:
                        protein, start, end = match.groups()

                        # Find most common 1-mer, 2-mer, and 3-mer
                        mono, mono_count = find_most_frequent_substring(sequence, 1)
                        di, di_count = find_most_frequent_substring(sequence, 2)
                        tri, tri_count = find_most_frequent_substring(sequence, 3)

                        seq_len = len(sequence)
                        mono_coverage = (len(mono) * mono_count) / seq_len
                        di_coverage = (len(di) * di_count) / seq_len
                        tri_coverage = (len(tri) * tri_count) / seq_len

                        # Write results
                        outfile.write(f"{protein}\t{start}\t{end}\t{mono}\t{mono_coverage:.6f}\t{di}\t{di_coverage:.6f}\t{tri}\t{tri_coverage:.6f}\n")
                
                # Start new sequence
                header = line
                sequence = ""
            else:
                sequence += line

        # Process last sequence
        if sequence and header:
            match = re.match(r">(.+):(\d+)-(\d+)", header)
            if match:
                protein, start, end = match.groups()

                mono, mono_count = find_most_frequent_substring(sequence, 1)
                di, di_count = find_most_frequent_substring(sequence, 2)
                tri, tri_count = find_most_frequent_substring(sequence, 3)

                seq_len = len(sequence)
                mono_coverage = (len(mono) * mono_count) / seq_len
                di_coverage = (len(di) * di_count) / seq_len
                tri_coverage = (len(tri) * tri_count) / seq_len

                outfile.write(f"{protein}\t{start}\t{end}\t{mono}\t{mono_coverage:.6f}\t{di}\t{di_coverage:.6f}\t{tri}\t{tri_coverage:.6f}\n")

# Process all `_gf` files
for file in os.listdir():
    if file.endswith("_gf"):
        print(f"Processing: {file}")
        process_fasta_file(file)

print("Processing complete. Output files saved with '_substrings.tsv' suffix.")

