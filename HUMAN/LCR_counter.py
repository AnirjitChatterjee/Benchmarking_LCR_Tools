import sys
from collections import Counter

def count_gene_occurrences(input_file, output_file):
    try:
        # Read the file and extract the first column
        with open(input_file, 'r') as file:
            lines = file.readlines()

        # Extract gene names from the first column
        genes = [line.split()[0] for line in lines if line.strip()]

        # Count occurrences of each gene
        gene_counts = Counter(genes)

        # Write the results to the output file
        with open(output_file, 'w') as output:
            for gene, count in gene_counts.items():
                output.write(f"{gene} {count}\n")

        print(f"Gene counts have been written to {output_file}")

    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Check if the user provided input and output file names
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        count_gene_occurrences(input_file, output_file)
