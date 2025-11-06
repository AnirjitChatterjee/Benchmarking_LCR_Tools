import sys
import math
from collections import Counter

def shannon_entropy(sequence):
    """Calculate Shannon's entropy for a given sequence safely."""
    freq = Counter(sequence)
    total_chars = len(sequence)
   
    if total_chars == 0:
        return 0  # Avoid division by zero
   
    entropy = 0
    for count in freq.values():
        prob = count / total_chars
        if prob > 0:  # Prevent log2(0) error
            entropy -= prob * math.log2(prob + 1e-10)  # Small epsilon added for stability

    return max(entropy, 0)  # Ensure entropy is non-negative

def simpson_diversity(sequence):
    """Calculate Simpson's Diversity Index for a given sequence."""
    freq = Counter(sequence)
    total_chars = len(sequence)
   
    if total_chars <= 1:
        return 0  # Avoid division by zero
   
    diversity = sum((count * (count - 1)) for count in freq.values()) / (total_chars * (total_chars - 1))
    return diversity

def process_fasta(input_file, output_file):
    """Reads a FASTA file, extracts LCR info, and calculates Shannon entropy & Simpson's diversity."""
    sequences = []
   
    with open(input_file, 'r') as infile:
        current_label = None
        current_sequence = []
       
        for line in infile:
            line = line.strip()
            if line.startswith(">"):  # Header line
                if current_label:
                    sequences.append((current_label, "".join(current_sequence)))  # Store previous sequence
                current_label = line[1:].split(":")  # Extract gene name and range
                gene_name = current_label[0]
                start, end = current_label[1].split("-") if len(current_label) > 1 else ("", "")
                current_sequence = []
            else:
                current_sequence.append(line)
       
        if current_label:
            sequences.append((current_label, "".join(current_sequence)))  # Store last sequence
   
    with open(output_file, 'w') as outfile:
        outfile.write("Gene\tStart\tEnd\tSequence\tShannon_Entropy\tSimpson_Diversity\n")  # Header
        for (label, seq) in sequences:
            gene_name, start_end = label[0], label[1] if len(label) > 1 else ""
            start, end = start_end.split("-") if "-" in start_end else ("", "")
            entropy = shannon_entropy(seq)
            simpson_d = simpson_diversity(seq)
            outfile.write(f"{gene_name}\t{start}\t{end}\t{seq}\t{entropy:.4f}\t{simpson_d:.4f}\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_fasta> <output_file>")
    else:
        process_fasta(sys.argv[1], sys.argv[2])
