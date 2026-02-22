import os
import glob

def process_fasta(file_path):
    output_file = file_path + "_processed.tsv"
    with open(file_path, "r") as infile, open(output_file, "w") as outfile:
        outfile.write("Protein\tStart\tEnd\tSequence\n")
        
        protein, start, end, sequence = None, None, None, ""
        for line in infile:
            line = line.strip()
            if line.startswith(">"):
                if protein and sequence:
                    outfile.write(f"{protein}\t{start}\t{end}\t{sequence}\n")
                
                header_parts = line[1:].split(":")
                protein = header_parts[0]
                start, end = map(int, header_parts[1].split("-"))
                sequence = ""
            else:
                sequence += line
        
        if protein and sequence:
            outfile.write(f"{protein}\t{start}\t{end}\t{sequence}\n")

def main():
    files = glob.glob("*_gf")
    for file in files:
        process_fasta(file)

if __name__ == "__main__":
    main()

