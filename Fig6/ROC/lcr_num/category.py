import os

def load_protein_names(txt_folder):
    """Loads protein names from each .txt file and stores them in a dictionary."""
    category_dict = {}
    for txt_file in os.listdir(txt_folder):
        if txt_file.endswith(".txt"):
            category_name = os.path.splitext(txt_file)[0]  # Get category name from filename
            txt_path = os.path.join(txt_folder, txt_file)
            with open(txt_path, 'r') as f:
                proteins = set(line.strip() for line in f if line.strip())
            category_dict[category_name] = proteins
    return category_dict

def filter_bed_files(bed_folder, category_dict, output_folder):
    """Filters .bed files based on protein names and writes categorized outputs."""
    os.makedirs(output_folder, exist_ok=True)
    
    for bed_file in os.listdir(bed_folder):
        if bed_file.endswith(".bed"):
            bed_path = os.path.join(bed_folder, bed_file)
            with open(bed_path, 'r') as f:
                bed_lines = [line.strip() for line in f if line.strip()]
            
            for category, proteins in category_dict.items():
                output_file = os.path.join(output_folder, f"{category}_{bed_file}")
                with open(output_file, 'w') as out_f:
                    for line in bed_lines:
                        parts = line.split('\t')
                        if parts and parts[0] in proteins:
                            out_f.write(line + '\n')

def main():
    txt_folder = "/home/anirjit/ANIRJIT/ROC2/human/lcr_num/category"  # Update with actual path
    bed_folder = "/home/anirjit/ANIRJIT/ROC2/human/lcr_num/truth"  # Update with actual path
    output_folder = "/home/anirjit/ANIRJIT/ROC2/human/lcr_num/output_truth"  # Update with actual path
    
    category_dict = load_protein_names(txt_folder)
    filter_bed_files(bed_folder, category_dict, output_folder)
    print("Processing complete. Filtered .bed files saved.")

if __name__ == "__main__":
    main()

