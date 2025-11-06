setwd("/home/anirjit/ANIRJIT/RESULTS/multiinter")

# Get all files ending with "_entropy_purity.tsv"
file_list <- list.files(pattern = "[0-9]+_gf_entropy_purity.tsv")

# Extract numeric prefixes and sort based on numbers
numeric_order <- as.numeric(gsub("_.*", "", file_list))  # Extract numeric part
file_list <- file_list[order(numeric_order)]  # Sort by extracted numbers

# Initialize an empty list to store entropy values
purity_data <- list()

# Read each file and extract "Entropy" column
for (file in file_list) {
  df <- read.table(file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  # Store entropy values in a list with numeric prefix as key
  purity_data[[gsub("_gf_entropy_purity.tsv", "", file)]] <- df$Purity
}

# Open a PNG device to save the plot
jpeg("purity_boxplot_sorted_baseR.jpg", width =1500, height = 1200, res = 250, quality = 50)

# Create a boxplot using base R
boxplot(purity_data, 
        main = "Boxplot of Purity across Groups of Tools", 
        xlab = "Number of tools", 
        ylab = "Purity",
        col = rainbow(length(purity_data)),   # Assign different colors
        las = 0,                               # Rotate x-axis labels
        cex.axis = 1,                        # Reduce text size
        outline = F)

# Close the PNG device
dev.off()
