from collections import Counter
import math
from Bio import SeqIO

# Function to calculate Shannon entropy
def shannon_entropy(sequence):
    counts = Counter(sequence)
    total = len(sequence)
    entropy = -sum((count / total) * math.log2(count / total) for count in counts.values())
    return entropy

# Input and output file paths
input_fasta = "human.fasta"
output_file = "human_entropy"

# Process the FASTA file and calculate entropy
with open(output_file, "w") as out:
    out.write("Protein\tEntropy\n")
    for record in SeqIO.parse(input_fasta, "fasta"):
        protein_name = record.id
        sequence = str(record.seq)
        entropy = shannon_entropy(sequence)
        out.write(f"{protein_name}\t{entropy:.4f}\n")

print(f"Entropy values saved to {output_file}")

