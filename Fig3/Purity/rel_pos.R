setwd("/home/anirjit/ANIRJIT/RESULTS/Rel_pos/human")

# Get all .bed files in the directory
files <- list.files(pattern = "\\.bed$")

for (file in files) {
  d1 <- read.delim(file, header = FALSE, sep = "\t")
  d1$V5 <- ((d1$V3 / d1$V4) + (d1$V2 / d1$V4)) / 2
  
  # Generate output filename
  output_file <- sub("\\.bed$", "_rel_pos", file)
  
  write.table(d1, file = output_file, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
}
