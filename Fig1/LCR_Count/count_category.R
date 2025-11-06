# Set working directory (Update this as needed)
setwd("/home/anirjit/ANIRJIT/RESULTS/LCR_Count/human/")

# List all files ending with "_lcr_count"
files <- list.files(pattern = "_lcr_count$")

# Total genes given in the problem
total_genes <- 20610

# Loop through each file
for (file in files) {
  # Read the current file
  data <- read.table(file, header = FALSE, sep = " ", stringsAsFactors = FALSE)
  
  # Rename columns for clarity
  colnames(data) <- c("Gene", "Count")
  
  # Categorize counts into bins
  categories <- c("0", "1-5", "5-10", "10-15", "15+")
  counts <- c(
    total_genes - nrow(data),    # Genes with 0 occurrences
    sum(data$Count >= 1 & data$Count < 5),
    sum(data$Count >= 5 & data$Count < 10),
    sum(data$Count >= 10 & data$Count < 15),
    sum(data$Count >= 15)
  )
  
  # Convert counts to percentage
  percentages <- (counts / total_genes) * 100
  
  # Combine counts and percentages into a data frame
  output <- data.frame(Category = categories, Count = counts, Percentage = percentages)
  
  # Save the output to a separate file based on the input file name
  output_filename <- paste0(sub("_lcr_count", "_categorized", file), ".tsv")
  write.table(output, output_filename, sep = "\t", row.names = FALSE, quote = FALSE)
  
  # Print message for each file
  message(paste("Processed", file, "and saved results to", output_filename))
}
