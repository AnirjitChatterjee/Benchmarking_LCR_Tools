import sys
import re
from collections import Counter

def parse_fasta(file_path):
    """Parses a FASTA file and extracts protein names, positions, and sequences."""
    sequences = []
    with open(file_path, 'r') as file:
        header, sequence = None, []
        for line in file:
            line = line.strip()
            if line.startswith('>'):
                if header:
                    sequences.append((header, ''.join(sequence)))
                header = line[1:]  # Remove '>'
                sequence = []
            else:
                sequence.append(line)
        if header:
            sequences.append((header, ''.join(sequence)))
    return sequences

def extract_info(header):
    """Extracts protein name, start, and end position from the header."""
    match = re.match(r'([^:]+):(\d+)-(\d+)', header)
    if match:
        return match.groups()
    return None, None, None

def find_most_frequent_char(sequence):
    """Finds the most repeated character in a given sequence."""
    counter = Counter(sequence)
    return max(counter, key=counter.get)

def process_fasta(input_file, output_file):
    """Processes the FASTA file and writes the results to an output file."""
    sequences = parse_fasta(input_file)
    with open(output_file, 'w') as out:
        out.write("Protein\tStart\tEnd\tMost_Repeated_Char\n")
        for header, sequence in sequences:
            protein, start, end = extract_info(header)
            if protein and start and end:
                most_frequent_char = find_most_frequent_char(sequence)
                out.write(f"{protein}\t{start}\t{end}\t{most_frequent_char}\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_fasta> <output_file>")
        sys.exit(1)
    input_fasta = sys.argv[1]
    output_file = sys.argv[2]
    process_fasta(input_fasta, output_file)
