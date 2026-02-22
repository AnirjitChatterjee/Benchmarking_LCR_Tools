import os

# === CONFIGURE THESE PATHS ===
bed_folder = "/home/anirjit/ANIRJIT/ROC2/human/entropy/pred"
txt_folder = "/home/anirjit/ANIRJIT/ROC2/human/entropy/category"
output_folder = "/home/anirjit/ANIRJIT/ROC2/human/entropy/output_pred"

os.makedirs(output_folder, exist_ok=True)

# Read all name lists into dictionaries
name_sets = {}
for txt_file in os.listdir(txt_folder):
    if txt_file.endswith(".txt"):
        category = os.path.splitext(txt_file)[0]
        with open(os.path.join(txt_folder, txt_file), "r") as f:
            names = set(line.strip() for line in f if line.strip())
            name_sets[category] = names

# Process each .bed file
for bed_file in os.listdir(bed_folder):
    if bed_file.endswith(".bed"):
        bed_path = os.path.join(bed_folder, bed_file)
        with open(bed_path, "r") as bf:
            bed_lines = bf.readlines()

        for category, name_set in name_sets.items():
            output_lines = [line for line in bed_lines if line.split()[0] in name_set]
            if output_lines:
                output_file = os.path.join(
                    output_folder, f"{os.path.splitext(bed_file)[0]}_{category}.bed"
                )
                with open(output_file, "w") as outf:
                    outf.writelines(output_lines)

print("✅ Categorization complete! Check your output folder.")

