import sys

def calculate_lcr_coverage(lcr_file, protein_file, output_file):
    try:
        # Read protein lengths into a dictionary
        protein_lengths = {}
        with open(protein_file, 'r') as pf:
            for line in pf:
                if line.strip():
                    parts = line.strip().split()
                    protein_lengths[parts[0]] = int(parts[1])

        # Calculate total LCR length for each protein
        lcr_lengths = {}
        with open(lcr_file, 'r') as lf:
            for line in lf:
                if line.strip():
                    parts = line.strip().split()
                    protein_name = parts[0]
                    lcr_length = int(parts[3])
                    if protein_name in protein_lengths:
                        if protein_name not in lcr_lengths:
                            lcr_lengths[protein_name] = 0
                        lcr_lengths[protein_name] += lcr_length

        # Calculate percentage of protein length covered by LCRs and write output
        with open(output_file, 'w') as of:
            of.write("Protein\tLCR_Coverage_Percentage\n")
            for protein, total_lcr_length in lcr_lengths.items():
                if protein in protein_lengths:
                    protein_length = protein_lengths[protein]
                    lcr_coverage = (total_lcr_length / protein_length) * 100
                    of.write(f"{protein}\t{lcr_coverage:.2f}\n")

        print(f"LCR coverage percentages written to {output_file}")

    except FileNotFoundError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <lcr_file> <protein_file> <output_file>")
    else:
        lcr_file = sys.argv[1]
        protein_file = sys.argv[2]
        output_file = sys.argv[3]
        calculate_lcr_coverage(lcr_file, protein_file, output_file)
