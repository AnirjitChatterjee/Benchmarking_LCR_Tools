import sys

# File paths
gene_lengths_file = "human_prot_length"  # Replace with actual path
lcr_lengths_file = "human_lcr_lengths"    # Replace with actual path
output_file = "human_lcr_frac"              # Output filename

# Load gene lengths into a dictionary
gene_lengths = {}
with open(gene_lengths_file, "r") as f:
    for line in f:
        parts = line.strip().split()
        if len(parts) == 2:
            gene_lengths[parts[0]] = int(parts[1])

# Process LCR lengths and calculate ratios
with open(lcr_lengths_file, "r") as f, open(output_file, "w") as out:
    out.write("Protein\tLCR_Length\tGene_Length\tRatio\n")  # Header
    for line in f:
        parts = line.strip().split()
        if len(parts) == 2:
            protein, lcr_length = parts[0], int(parts[1])
            if protein in gene_lengths:
                gene_length = gene_lengths[protein]
                ratio = lcr_length / gene_length if gene_length > 0 else 0
                out.write(f"{protein}\t{lcr_length}\t{gene_length}\t{ratio:.4f}\n")

print(f"Output saved to {output_file}")

