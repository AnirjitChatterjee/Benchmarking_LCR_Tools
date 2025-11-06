import sys
import re

def extract_lcr_data(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        protein_name = None
        for line in infile:
            if "repeat not found in sequence" in line:
                continue
           
            match = re.match(r">[\w|]+?\|([\w\d]+)_SALSA", line)
            if match:
                protein_name = match.group(1)
           
            lcr_match = re.match(r"Length: \d+ residues - nb: \d+  from\s+(\d+)\s+to\s+(\d+)", line)
            if lcr_match and protein_name:
                start, end = lcr_match.groups()
                outfile.write(f"{protein_name}\t{start}\t{end}\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
        sys.exit(1)
   
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    extract_lcr_data(input_file, output_file)
