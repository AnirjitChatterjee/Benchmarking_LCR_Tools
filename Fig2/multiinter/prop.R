setwd("/home/anirjit/ANIRJIT/RESULTS/multiinter")
library(dplyr)

# Get all files ending with "_peptide_counts.tsv"
files <- list.files(pattern = "_peptide_counts.tsv$")

# Loop through each file
for (file in files) {
  # Read the data
  data <- read.delim(file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # Compute proportions
  total_count <- sum(data$Count)
  data$Proportion <- data$Count / total_count
  
  # Write the updated data back to the same file
  write.table(data, file = file, sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
  
  # Print confirmation message
  print(paste("Processed and updated:", file))
}

print("All files updated successfully!")
