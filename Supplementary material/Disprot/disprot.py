import pandas as pd

# Load files
coords = pd.read_csv(
    "human_disprot_coordinates",
    sep="\t",
    header=None,
    names=["uniprot", "start", "end"]
)

mapping = pd.read_csv(
    "Disprot_uniprot",
    sep="\t",
    header=None,
    names=["uniprot", "gene"]
)

# Replace UniProt IDs with gene symbols
coords = coords.merge(mapping, on="uniprot", how="left")

# Drop entries without a gene symbol
coords = coords.dropna(subset=["gene"])

# Function to merge overlapping intervals
def merge_intervals(df):
    df = df.sort_values("start")
    merged = []
    for s, e in zip(df.start, df.end):
        if not merged or s > merged[-1][1] + 1:
            merged.append([s, e])
        else:
            merged[-1][1] = max(merged[-1][1], e)
    return pd.DataFrame(merged, columns=["start", "end"])

# Apply per gene
out = []
for gene, gdf in coords.groupby("gene"):
    merged_df = merge_intervals(gdf)
    merged_df["gene"] = gene
    out.append(merged_df)

final = (
    pd.concat(out)
    .loc[:, ["gene", "start", "end"]]
    .sort_values(["gene", "start"])
)

# Save result
final.to_csv(
    "human_disprot.bed",
    sep="\t",
    index=False,
    header=False
)

