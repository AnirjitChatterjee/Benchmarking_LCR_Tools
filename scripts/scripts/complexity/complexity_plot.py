import sys
import math
from collections import Counter
from Bio import SeqIO

def read_bed(file):
    """Read BED file and return a list of tuples (protein_id, start, end)."""
    bed_regions = []
    with open(file, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 3:
                bed_regions.append((parts[0], int(parts[1]), int(parts[2])))
    return bed_regions

def extract_sequences(fasta_file, bed_regions):
    """Extract sequences from the protein FASTA file based on BED regions."""
    sequences = {}
    for record in SeqIO.parse(fasta_file, "fasta"):
        sequences[record.id] = str(record.seq)
    extracted = []
    for protein_id, start, end in bed_regions:
        if protein_id in sequences:
            extracted.append((protein_id, start, end, sequences[protein_id][start:end]))
    return extracted

def calculate_entropy(sequence):
    """Calculate Shannon entropy of a sequence."""
    length = len(sequence)
    freqs = Counter(sequence)
    return -sum((count / length) * math.log2(count / length) for count in freqs.values())

def find_most_frequent_aa(sequence):
    """Find the most frequent amino acid and its percentage in the sequence."""
    freqs = Counter(sequence)
    most_common_aa, most_common_count = freqs.most_common(1)[0]
    return most_common_aa, (most_common_count / len(sequence)) * 100

def find_kmers(sequence):
    """Find k-mers of length 1 to len(sequence)-1 that appear at least twice."""
    kmer_counts = {}
    for k in range(1, len(sequence)):
        seen = Counter()
        for i in range(len(sequence) - k + 1):
            kmer = sequence[i:i+k]
            seen[kmer] += 1
        kmer_counts[k] = {kmer: count for kmer, count in seen.items() if count > 1}
    return kmer_counts

def min_mutation_percent(sequence, kmer_counts):
    """Find the k-mer that requires the fewest mutations to make the sequence fully repetitive."""
    min_mutations = len(sequence)
    best_kmer = None
    mutation_data = []
    
    for k, kmers in kmer_counts.items():
        for kmer in kmers:
            repetitions = sequence.count(kmer)
            required_mutations = len(sequence) - (repetitions * len(kmer))
            mutation_percent = (required_mutations / len(sequence)) * 100
            mutation_data.append(f"{kmer}:{mutation_percent:.2f}")
            
            if required_mutations < min_mutations:
                min_mutations = required_mutations
                best_kmer = kmer
    
    overall_mutation_percent = (min_mutations / len(sequence)) * 100 if best_kmer else 100
    return best_kmer, overall_mutation_percent, ",".join(mutation_data)

def main(fasta_file, bed_file, output_file):
    bed_regions = read_bed(bed_file)
    extracted_sequences = extract_sequences(fasta_file, bed_regions)
    
    with open(output_file, 'w') as out:
        out.write("Protein_ID\tStart\tEnd\tEntropy\tMost_Frequent_AA\tMost_Frequent_AA_Percent\tKmers_At_Least_Twice\tBest_Kmer\tMutation_Percent\tKmer_Mutation_List\tSequence\n")
        
        for protein_id, start, end, sequence in extracted_sequences:
            entropy = calculate_entropy(sequence)
            most_freq_aa, most_freq_aa_percent = find_most_frequent_aa(sequence)
            kmer_counts = find_kmers(sequence)
            best_kmer, mutation_percent, mutation_list = min_mutation_percent(sequence, kmer_counts)
            kmer_list = ",".join([kmer for kmers in kmer_counts.values() for kmer in kmers])
            
            out.write(f"{protein_id}\t{start}\t{end}\t{entropy:.4f}\t{most_freq_aa}\t{most_freq_aa_percent:.2f}\t{kmer_list}\t{best_kmer}\t{mutation_percent:.2f}\t{mutation_list}\t{sequence}\n")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <protein_fasta> <bed_file> <output_file>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3])

