import os
import glob

def read_txt_files(txt_folder):
    """Read all .txt files and store protein names by category."""
    category_dict = {}
    txt_files = glob.glob(os.path.join(txt_folder, "*.txt"))
    
    for txt_file in txt_files:
        category_name = os.path.splitext(os.path.basename(txt_file))[0]
        category_dict[category_name] = set()
        
        with open(txt_file, 'r') as f:
            for line in f:
                protein = line.split('\t')[0]  # Extract protein name
                category_dict[category_name].add(protein)
    
    return category_dict

def categorize_bed_files(bed_folder, output_folder, category_dict):
    """Categorize .bed files based on the proteins present in .txt files."""
    bed_files = glob.glob(os.path.join(bed_folder, "*.bed"))
    os.makedirs(output_folder, exist_ok=True)
    
    for bed_file in bed_files:
        base_name = os.path.splitext(os.path.basename(bed_file))[0]
        
        # Create output files for each category
        output_files = {cat: open(os.path.join(output_folder, f"{base_name}_{cat}.bed"), 'w') for cat in category_dict}
        
        with open(bed_file, 'r') as f:
            for line in f:
                protein = line.split('\t')[0]  # Extract protein name
                
                for category, proteins in category_dict.items():
                    if protein in proteins:
                        output_files[category].write(line)
        
        # Close all output files
        for f in output_files.values():
            f.close()

if __name__ == "__main__":
    txt_folder = "/home/anirjit/ANIRJIT/ROC2/human/test2/category"  # Change to actual path
    bed_folder = "/home/anirjit/ANIRJIT/ROC2/human/test2/truth"  # Change to actual path
    output_folder = "/home/anirjit/ANIRJIT/ROC2/human/test2/output_truth"  # Change to actual path
    
    category_dict = read_txt_files(txt_folder)
    categorize_bed_files(bed_folder, output_folder, category_dict)
    
    print("Categorization complete!")

