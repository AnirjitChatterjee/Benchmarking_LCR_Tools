import sys
from collections import Counter

def process_file(input_file, output_file):
    substring_counts = Counter()
    total_entries = 0
   
    with open(input_file, 'r') as infile:
        for line in infile:
            columns = line.strip().split('\t')
            if len(columns) >= 4:
                repeat_unit = columns[3]
                substring_counts[repeat_unit] += 1
                total_entries += 1
   
    sorted_substrings = sorted(substring_counts.items(), key=lambda x: x[1], reverse=True)
   
    with open(output_file, 'w') as outfile:
        outfile.write("Substring\tCount\tPercentage\n")
        for substring, count in sorted_substrings:
            percentage = (count / total_entries) * 100
            outfile.write(f"{substring}\t{count}\t{percentage:.2f}%\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
    else:
        process_file(sys.argv[1], sys.argv[2])
