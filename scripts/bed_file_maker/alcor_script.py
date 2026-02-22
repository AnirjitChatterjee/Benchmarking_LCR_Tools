#!/usr/bin/env python3

import os
from Bio import SeqIO

# -------------------------------
# Step 1: Extract LCRs from a sequence
# -------------------------------

def read_sequence(file_path):
    """Read the full protein sequence from file."""
    with open(file_path, 'r') as f:
        return f.read().strip()

def read_coordinates(file_path):
    """Read start-end coordinates from a file."""
    coords = []
    with open(file_path, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 2:
                start, end = int(parts[0]), int(parts[1])
                coords.append((start, end))
            else:
                print(f"Skipping invalid line: {line.strip()}")
    return coords

def extract_lcrs(sequence, coordinates):
    """Extract LCR sequences given start-end positions."""
    return [(start, end, sequence[start-1:end]) for start, end in coordinates]

def write_lcrs(lcrs, output_file):
    """Write extracted LCRs to file."""
    with open(output_file, 'w') as f:
        for start, end, lcr in lcrs:
            f.write(f"{start}\t{end}\t{lcr}\n")
    print(f"Extracted LCRs written to: {output_file}")

# -------------------------------
# Step 2: Map LCRs to FASTA database
# -------------------------------

def search_lcrs_in_fasta(lcrs, fasta_file):
    """Search for extracted LCRs in FASTA sequences."""
    matches = []
    for record in SeqIO.parse(fasta_file, "fasta"):
        seq = str(record.seq)
        protein = record.id
        for _, _, lcr in lcrs:
            start = seq.find(lcr)
            if start != -1:
                end = start + len(lcr)
                matches.append((protein, start + 1, end))
    return matches

def write_matches(matches, output_file):
    """Write LCR match coordinates to file."""
    with open(output_file, 'w') as f:
        for protein, start, end in matches:
            f.write(f"{protein}\t{start}\t{end}\n")
    print(f"LCR matches written to: {output_file}")

# -------------------------------
# Main workflow
# -------------------------------

if __name__ == "__main__":
    # === Define file paths (edit these) ===
    sequence_file = "/home/ceglab5/Desktop/simulations/src/lcr_400/extract"
    coordinates_file = "/home/ceglab5/Desktop/simulations/src/lcr_400/mapper_res"
    fasta_file = "/home/ceglab5/Desktop/simulations/src/lcr_400/appended_sequences_2.fasta"

    lcr_output_file = "/home/ceglab5/Desktop/simulations/src/lcr_400/extract_result"
    coords_output_file = "/home/ceglab5/Desktop/simulations/src/lcr_400/alcor_coords"

    # === Step 1: Extract LCRs ===
    sequence = read_sequence(sequence_file)
    coordinates = read_coordinates(coordinates_file)
    lcrs = extract_lcrs(sequence, coordinates)
    write_lcrs(lcrs, lcr_output_file)

    # === Step 2: Search and map LCRs ===
    matches = search_lcrs_in_fasta(lcrs, fasta_file)
    write_matches(matches, coords_output_file)

    print("\n✅ LCR extraction and mapping complete!")

