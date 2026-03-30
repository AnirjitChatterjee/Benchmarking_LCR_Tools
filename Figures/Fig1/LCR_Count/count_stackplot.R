# Load required libraries
library(ggplot2)
library(viridis)
library(tidyverse)

# Set working directory (Update this as needed)
setwd("/home/anirjit/ANIRJIT/RESULTS/LCR_Count/human/")

# Get list of all categorized TSV files
files <- list.files(pattern = "_categorized.tsv$")

# Initialize an empty dataframe to store data from all files
all_data <- data.frame(File = character(), Category = character(), Count = numeric())

# Loop through each file
for (file in files) {
  
  # Read the categorized data
  data <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  
  # Extract filename (removing "_categorized.tsv" for clarity)
  file_name <- gsub("_categorized.tsv", "", file)
  
  # Add filename as a column
  data$File <- file_name
  
  # Append to main dataframe
  all_data <- rbind(all_data, data)
}

# Convert category column to factor with correct order
all_data$Category <- factor(all_data$Category, levels = c("0", "1-5", "5-10", "10-15", "15+"))
jpeg("human_lcr_count.jpg", width = 6000, height = 4500, res = 1000)
# Create stacked bar plot
ggplot(all_data, aes(x = File, y = Count, fill = Category)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_viridis_d(option = "plasma", name = "LCR Counts") +  # Color-blind friendly palette
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 16),
        axis.text.x = element_text(angle = 45, vjust = 1, size = 6, colour = "black"),
        axis.text.y = element_text(angle = 0, vjust = 1, size = 8, colour = "black"),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        panel.grid.major = element_blank(),  # Remove grid
        panel.grid.minor = element_blank()) +
  scale_x_discrete(labels = c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS 2.0", "fLPS 2.0\nstrict", "fLPS\nstrict", "LCRFinder",
                              "SEG", "SEG\nIntermediate", "SEG\nstrict", "T-REKS", "Xstream")) +
  scale_y_continuous(breaks = seq(0, max(all_data$Count), by = 5000)) + 
  labs(title = "LCR Counts of" ~bolditalic("Homo sapiens"),
       x = "Tools",
       y = "LCR Counts") +
  theme(legend.position = "right")
dev.off()
