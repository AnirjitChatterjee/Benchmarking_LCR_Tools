#!/usr/bin/env python3

import sys
import math
from collections import Counter
from Bio import SeqIO

# -----------------------------
# BED reader
# -----------------------------
def read_bed(file):
    regions = []
    with open(file) as f:
        for line in f:
            if line.strip() == "" or line.startswith("#"):
                continue
            p, s, e = line.strip().split()[:3]
            regions.append((p, int(s), int(e)))
    return regions

# -----------------------------
# Extract sequences safely
# -----------------------------
def extract_sequences(fasta_file, bed_regions):
    seqs = {rec.id: str(rec.seq) for rec in SeqIO.parse(fasta_file, "fasta")}
    extracted = []

    for pid, start, end in bed_regions:
        if pid not in seqs:
            continue

        # BED assumed 1-based inclusive → Python 0-based exclusive
        s = max(0, start - 1)
        e = min(len(seqs[pid]), end)

        if e <= s:
            continue

        fragment = seqs[pid][s:e]
        if fragment:
            extracted.append((pid, start, end, fragment))

    return extracted

# -----------------------------
# Shannon entropy
# -----------------------------
def calculate_entropy(sequence):
    if not sequence:
        return 0.0
    length = len(sequence)
    freqs = Counter(sequence)
    return -sum(
        (c / length) * math.log2(c / length)
        for c in freqs.values()
    )

# -----------------------------
# Most frequent AA
# -----------------------------
def find_most_frequent_aa(sequence):
    if not sequence:
        return "NA", 0.0
    freqs = Counter(sequence)
    aa, count = freqs.most_common(1)[0]
    return aa, (count / len(sequence)) * 100

# -----------------------------
# k-mer analysis
# -----------------------------
def find_kmers(sequence):
    kmer_counts = {}
    L = len(sequence)
    for k in range(1, L):
        counts = Counter(sequence[i:i+k] for i in range(L - k + 1))
        kmer_counts[k] = {kmer: c for kmer, c in counts.items() if c > 1}
    return kmer_counts

# -----------------------------
# Mutation percent
# -----------------------------
def min_mutation_percent(sequence, kmer_counts):
    if not sequence:
        return "NA", 100.0, ""

    min_mut = len(sequence)
    best_kmer = None
    mutation_list = []

    for k, kmers in kmer_counts.items():
        for kmer in kmers:
            reps = sequence.count(kmer)
            mutations = len(sequence) - reps * len(kmer)
            perc = (mutations / len(sequence)) * 100
            mutation_list.append(f"{kmer}:{perc:.2f}")

            if mutations < min_mut:
                min_mut = mutations
                best_kmer = kmer

    final_percent = (min_mut / len(sequence)) * 100 if best_kmer else 100.0
    return best_kmer if best_kmer else "NA", final_percent, ",".join(mutation_list)

# -----------------------------
# Main
# -----------------------------
def main(fasta_file, bed_file, output_file):
    bed = read_bed(bed_file)
    regions = extract_sequences(fasta_file, bed)

    with open(output_file, "w") as out:
        out.write(
            "Protein_ID\tStart\tEnd\tEntropy\tMost_Frequent_AA\t"
            "Most_Frequent_AA_Percent\tBest_Kmer\tMutation_Percent\tSequence\n"
        )

        for pid, start, end, seq in regions:
            entropy = calculate_entropy(seq)
            aa, aa_perc = find_most_frequent_aa(seq)
            kmer_counts = find_kmers(seq)
            best_kmer, mut_perc, _ = min_mutation_percent(seq, kmer_counts)

            out.write(
                f"{pid}\t{start}\t{end}\t{entropy:.4f}\t"
                f"{aa}\t{aa_perc:.2f}\t{best_kmer}\t{mut_perc:.2f}\t{seq}\n"
            )

# -----------------------------
if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit("Usage: python script.py <proteome.fasta> <regions.bed> <output.tsv>")
    main(sys.argv[1], sys.argv[2], sys.argv[3])

