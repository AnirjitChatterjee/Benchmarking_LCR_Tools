import sys

def process_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            columns = line.strip().split('\t')
            if len(columns) >= 4:
                repeat_unit = columns[3]
                repeat_length = len(repeat_unit)
                outfile.write('\t'.join(columns + [str(repeat_length)]) + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
    else:
        process_file(sys.argv[1], sys.argv[2])
