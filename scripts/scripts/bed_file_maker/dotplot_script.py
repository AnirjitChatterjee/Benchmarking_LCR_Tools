from Bio import SeqIO

# Function to find the LCR in a sequence and return its start and end coordinates
def find_lcr(sequence, lcr):
    start_index = sequence.find(lcr)
    if start_index != -1:
        end_index = start_index + len(lcr) - 1
        return start_index + 1, end_index + 1
    else:
        return None, None

# Read the protein and LCR sequences from the file
protein_lcr_file = 'LCR_takru'
protein_lcr_dict = {}
with open(protein_lcr_file, 'r') as file:
    for line in file:
        parts = line.strip().split()
        protein_name = parts[0]
        lcr = parts[1]
        if protein_name not in protein_lcr_dict:
            protein_lcr_dict[protein_name] = []
        protein_lcr_dict[protein_name].append(lcr)

# Read the FASTA sequences and search for the LCRs
fasta_file = '/home/ceglab5/Desktop/Input_files/2_12_takru_proteome_UP000005226_31033_21256.fasta'
output_file = 'takru_dotplot_output'

with open(output_file, 'w') as out_file:
    for record in SeqIO.parse(fasta_file, 'fasta'):
        header = record.description
        sequence = str(record.seq)

        for protein_name in protein_lcr_dict:
            if protein_name in header:
                for lcr in protein_lcr_dict[protein_name]:
                    start, end = find_lcr(sequence, lcr)
                    if start is not None:
                        out_file.write(f"{protein_name}	{start}	{end}\n")
