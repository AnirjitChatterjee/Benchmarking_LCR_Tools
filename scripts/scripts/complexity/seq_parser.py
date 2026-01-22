#!/usr/bin/env python3

import argparse
from Bio import SeqIO

def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate sliding windows over protein sequences and output BED-like coordinates"
    )
    parser.add_argument(
        "-i", "--input",
        required=True,
        help="Input proteome FASTA file"
    )
    parser.add_argument(
        "-w", "--window",
        type=int,
        required=True,
        help="Window size (e.g. 20)"
    )
    parser.add_argument(
        "-s", "--step",
        type=int,
        required=True,
        help="Sliding step size (e.g. 10)"
    )
    parser.add_argument(
        "-o", "--output",
        required=True,
        help="Output BED-like file"
    )
    return parser.parse_args()

def main():
    args = parse_args()

    window = args.window
    step = args.step

    if step <= 0 or window <= 0:
        raise ValueError("Window and step sizes must be positive integers")

    with open(args.output, "w") as out:
        for record in SeqIO.parse(args.input, "fasta"):
            protein_id = record.id
            seq_len = len(record.seq)

            for start in range(0, seq_len, step):
                end = start + window

                if start >= seq_len:
                    break

                # Clip end to sequence length
                end = min(end, seq_len)

                # Convert to 1-based inclusive coordinates
                bed_start = start + 1
                bed_end = end

                out.write(
                    f"{protein_id}\t{bed_start}\t{bed_end}\n"
                )

if __name__ == "__main__":
    main()

