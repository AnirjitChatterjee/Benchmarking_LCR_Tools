import sys

def build_suffix_array(sequence):
    """Builds a suffix array for the given sequence."""
    suffixes = sorted((sequence[i:], i) for i in range(len(sequence)))
    suffix_array = [suffix[1] for suffix in suffixes]
    return suffix_array

def build_lcp_array(sequence, suffix_array):
    """Computes the longest common prefix (LCP) array."""
    n = len(sequence)
    rank = [0] * n
    lcp = [0] * (n - 1)

    for i, suffix_index in enumerate(suffix_array):
        rank[suffix_index] = i

    h = 0
    for i in range(n):
        if rank[i] > 0:
            j = suffix_array[rank[i] - 1]
            while i + h < n and j + h < n and sequence[i + h] == sequence[j + h]:
                h += 1
            lcp[rank[i] - 1] = h
            if h > 0:
                h -= 1
    return lcp

def find_largest_repeat(sequence):
    """Finds the largest repeating unit in a given sequence using a suffix array."""
    if not sequence:
        return ""

    suffix_array = build_suffix_array(sequence)
    lcp_array = build_lcp_array(sequence, suffix_array)

    max_length = max(lcp_array, default=0)
    if max_length == 0:
        return ""  # No repeating substring found

    max_index = lcp_array.index(max_length)
    largest_repeat = sequence[suffix_array[max_index]: suffix_array[max_index] + max_length]

    return largest_repeat

def process_fasta(input_file, output_file):
    """Reads a FASTA file, extracts metadata, finds the largest repeat, and writes output."""
    results = []
   
    with open(input_file, "r") as f:
        protein_name, start, end, sequence = None, None, None, []

        for line in f:
            line = line.strip()
            if line.startswith(">"):
                if protein_name and sequence:
                    # Process the last sequence
                    largest_repeat = find_largest_repeat("".join(sequence))
                    results.append(f"{protein_name}\t{start}\t{end}\t{largest_repeat}")

                # Extract new sequence metadata
                header_parts = line[1:].split(":")
                protein_name = header_parts[0]
                start, end = map(int, header_parts[1].split("-"))
                sequence = []
            else:
                sequence.append(line)

        # Process the last entry
        if protein_name and sequence:
            largest_repeat = find_largest_repeat("".join(sequence))
            results.append(f"{protein_name}\t{start}\t{end}\t{largest_repeat}")

    # Write output to file
    with open(output_file, "w") as f_out:
        f_out.write("\n".join(results))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input.fasta> <output.txt>")
        sys.exit(1)

    input_fasta = sys.argv[1]
    output_file = sys.argv[2]
    process_fasta(input_fasta, output_file)
    print(f"Results written to {output_file}")
