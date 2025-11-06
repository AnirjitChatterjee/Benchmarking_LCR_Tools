setwd("/home/anirjit/ANIRJIT/RESULTS/Purity/human")

# Get all .txt files in the directory
files <- list.files(pattern = "\\.txt$")

for (file in files) {
  # Check if the file is empty
  if (file.info(file)$size == 0) {
    print(paste("Skipping empty file:", file))
    next
  }
  
  d1 <- read.delim(file, header = FALSE, sep = "\t")
  
  # Ensure the file has at least 7 columns before modifying V7
  if (ncol(d1) < 6) {
    print(paste("Skipping file due to insufficient columns:", file))
    next
  }
  
  # Modify V7 column in-place
  d1$V7 <- ((d1$V3 / d1$V6) + (d1$V2 / d1$V6)) / 2
  
  # Overwrite the same file
  write.table(d1, file = file, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
}

print("Files updated successfully!")
