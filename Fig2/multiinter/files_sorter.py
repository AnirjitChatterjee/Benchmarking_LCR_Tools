import pandas as pd

# Read the file
df = pd.read_csv("human_multiinter_results", sep="\t", header=None)

# Group by the 4th column (index 3)
for value, group in df.groupby(df[3]):
    filename = f"{value}.tsv"  # Create a filename based on the value
    group.to_csv(filename, sep="\t", header=False, index=False)  # Save to file
    print(f"Saved {filename}")

