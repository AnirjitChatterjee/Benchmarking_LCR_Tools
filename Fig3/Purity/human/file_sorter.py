import os

# Get all files ending with "_processed.txt"
file_list = [f for f in os.listdir() if f.endswith(".txt")]

def sort_bed_file(input_file):
    output_file = input_file.replace(".txt", "_sorted.bed")

    # Read and sort the file
    with open(input_file, "r") as f:
        lines = [line.strip().split("\t") for line in f.readlines()]
    
    # Sort first by column 1 (string), then by column 2 (numeric)
    sorted_lines = sorted(lines, key=lambda x: (x[0], int(x[1])))

    # Write sorted output to new file
    with open(output_file, "w") as out_f:
        for line in sorted_lines:
            out_f.write("\t".join(line) + "\n")

    print(f"Sorted file created: {output_file}")

# Process each _processed.txt file
for file in file_list:
    sort_bed_file(file)

print("Sorting completed for all files.")

