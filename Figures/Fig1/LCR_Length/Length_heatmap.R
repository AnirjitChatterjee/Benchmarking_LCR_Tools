# Load required libraries
library(ggplot2)
library(viridis)
library(reshape2)
library(tidyverse)

# Set working directory (update as needed)
setwd("/home/anirjit/ANIRJIT/RESULTS/LCR_Length/human")

# Get list of all categorized TSV files
files <- list.files(pattern = "_categorized.tsv$")

# Initialize an empty dataframe
all_data <- data.frame(File = character(), Category = character(), Count = numeric())

# Loop through each file and read data
for (file in files) {
  # Read categorized data
  data <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  
  # Extract file name without extension
  file_name <- gsub("_categorized.tsv", "", file)
  
  # Add filename as a column
  data$File <- file_name
  
  # Append to the main dataframe
  all_data <- rbind(all_data, data)
}

# Convert to proper format for heatmap
all_data$Category <- factor(all_data$Category, levels = c("0-10", "10-20", "20-50", "50-100", "100-200", "200+"))
all_data$File <- factor(all_data$File, levels = unique(all_data$File))

jpeg("human_lcr_length.jpg", width = 6000, height = 4500, res = 1000)
# Create heatmap
ggplot(all_data, aes(x = Category, y = File, fill = Count)) +
  geom_tile() +
  scale_fill_viridis(option = "magma", name = "LCR Count", direction = -1) +  # Color-blind-friendly palette
  theme_minimal() +
  labs(title = "LCR Length Distributions for"~bolditalic("Homo sapiens"),
       x = "LCR Length Category",
       y = "Tool") +
  theme(plot.title = element_text(hjust = 0.5, size = 16),
        axis.text.x = element_text(angle = 0, vjust = 1, size = 9, colour = "black"),
        axis.text.y = element_text(angle = 0, vjust = 1, size = 8, colour = "black"),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        panel.grid.major = element_blank(),  # Remove grid
        panel.grid.minor = element_blank()) +
  scale_y_discrete(labels = c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS\nstrict", "fLPS 2.0", "fLPS 2.0\nstrict", "LCRFinder",
                             "SEG", "SEG\nIntermediate", "SEG\nstrict", "T-REKS", "Xstream"))
dev.off()
