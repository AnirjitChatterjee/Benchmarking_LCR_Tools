#!/usr/bin/env python3

import pandas as pd

# ===============================
# INPUT / OUTPUT FILES
# ===============================
input_file = "uniprot_segments_observed.csv"
output_file = "human_pdb_missing_residues.bed"

# ===============================
# LOAD FILE (ROBUSTLY)
# ===============================
df = pd.read_csv(
    input_file,
    sep=",",          # SIFTS files are TAB-separated
    comment="#",       # Ignore comment lines if present
    dtype=str          # Read everything as string first
)

# Clean column names
df.columns = df.columns.str.strip()

# Explicit sanity check
expected_cols = [
    "PDB", "CHAIN", "SP_PRIMARY",
    "RES_BEG", "RES_END",
    "PDB_BEG", "PDB_END",
    "SP_BEG", "SP_END"
]

if not set(expected_cols).issubset(df.columns):
    raise ValueError(
        f"Unexpected columns found:\n{df.columns.tolist()}"
    )

# ===============================
# KEEP ONLY WHAT WE NEED
# ===============================
df = df[["SP_PRIMARY", "RES_BEG", "RES_END"]]

# Convert coordinates to integers
df["RES_BEG"] = df["RES_BEG"].astype(int)
df["RES_END"] = df["RES_END"].astype(int)

# Sort properly
df = df.sort_values(
    ["SP_PRIMARY", "RES_BEG", "RES_END"]
)

# ===============================
# COMPUTE MISSING RESIDUES
# ===============================
missing_regions = []

for uniprot, group in df.groupby("SP_PRIMARY"):
    group = group.sort_values("RES_BEG")

    current_end = None

    for _, row in group.iterrows():
        beg = row.RES_BEG
        end = row.RES_END

        # First observed segment
        if current_end is None:
            if beg > 1:
                missing_regions.append(
                    [uniprot, 1, beg - 1]
                )
            current_end = end

        # Gap between observed segments
        else:
            if beg > current_end + 1:
                missing_regions.append(
                    [uniprot, current_end + 1, beg - 1]
                )
            current_end = max(current_end, end)

# ===============================
# WRITE OUTPUT
# ===============================
missing_df = pd.DataFrame(
    missing_regions,
    columns=["UniProt", "start", "end"]
)

missing_df.to_csv(
    output_file,
    sep="\t",
    index=False,
    header=False
)

print(f"Done. Missing residues written to: {output_file}")

