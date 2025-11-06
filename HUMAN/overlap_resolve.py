import pandas as pd
import sys

# Function to merge overlapping intervals
def merge_intervals(intervals):
    # Sort intervals by the start position
    intervals.sort(key=lambda x: x[0])
    merged = []
    for interval in intervals:
        if not merged or merged[-1][1] < interval[0] - 1:
            merged.append(interval)  # No overlap
        else:
            # Merge overlapping intervals
            merged[-1][1] = max(merged[-1][1], interval[1])
    return merged

def main(input_file, output_file):
    # Load the data
    data = pd.read_csv(input_file, sep='\s+', header=None, names=["Sequence", "Start", "End"])

    # Process each sequence
    result = []
    for sequence in data["Sequence"].unique():
        sequence_data = data[data["Sequence"] == sequence]
        intervals = sequence_data[["Start", "End"]].values.tolist()
        merged_intervals = merge_intervals(intervals)
        for start, end in merged_intervals:
            result.append([sequence, start, end])

    # Convert results back to a DataFrame
    merged_data = pd.DataFrame(result, columns=["Sequence", "Start", "End"])

    # Save the output
    merged_data.to_csv(output_file, sep="\t", index=False, header=False)
    print(f"Merged coordinates have been saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        main(input_file, output_file)

