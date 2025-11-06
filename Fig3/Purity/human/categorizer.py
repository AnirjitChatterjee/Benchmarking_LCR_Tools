import os

# Define the cutoff categories
cutoff_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

# Get all files ending with "_processed.txt"
file_list = [f for f in os.listdir() if f.endswith("_processed.txt")]

def filter_by_cutoff(input_file):
    # Read input file
    with open(input_file, "r") as f:
        lines = f.readlines()
    
    # Process each cutoff value
    for cutoff in cutoff_values:
        output_file = input_file.replace("_processed.txt", f"_filtered_{cutoff}.txt")
        
        with open(output_file, "w") as out_f:
            for line in lines:
                columns = line.strip().split("\t")
                if len(columns) >= 5 and float(columns[4]) > cutoff:
                    out_f.write(line)
    
    print(f"Filtering complete for {input_file}")

# Process each _processed.txt file
for file in file_list:
    filter_by_cutoff(file)

print("All files have been processed and filtered.")

