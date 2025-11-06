import sys
import numpy as np
from collections import Counter

def shannon_entropy(sequence):
    counts = Counter(sequence)
    total = sum(counts.values())
    probabilities = [count / total for count in counts.values()]
    entropy = -sum(p * np.log2(p) for p in probabilities if p > 0)
    return entropy

def process_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            parts = line.strip().split()
            if len(parts) < 4:
                continue  # Skip lines with insufficient columns
            entropy = shannon_entropy(parts[3])
            outfile.write("\t".join(parts + [str(entropy)]) + "\n")

if __name__ == "__main__":
    input_path = "human_truth_gf"
    output_path = "human_truth_entropy"
    process_file(input_path, output_path)
    print(f"Entropy values added. Output saved to: {output_path}")

