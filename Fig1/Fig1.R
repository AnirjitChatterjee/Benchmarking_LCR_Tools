# Load required libraries
library(ggplot2)
library(viridis)
library(reshape2)
library(tidyverse)
library(dplyr)
library(tidyr)

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

# Create heatmap
p1 <- ggplot(all_data, aes(x = Category, y = File, fill = Count)) +
  geom_tile() +
  scale_fill_viridis(option = "magma", name = "LCR Counts", direction = -1) +  # Color-blind-friendly palette
  theme_minimal() +
  labs(x = "LCR Length Category",
       y = "Methods") +
  theme(plot.title = element_text(hjust = 0.5, size = 16),
        axis.text.x = element_text(angle = 0, vjust = 1, size = 10, colour = "black"),
        axis.text.y = element_text(angle = 0, vjust = 1, size = 10, colour = "black"),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        panel.grid.major = element_blank(),  # Remove grid
        panel.grid.minor = element_blank()) +
  scale_y_discrete(labels = c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS\nstrict", "fLPS 2.0", "fLPS 2.0\nstrict", "LCRFinder",
                              "SEG", "SEG\nIntermediate", "SEG\nstrict", "T-REKS", "Xstream"))



# Set working directory (modify as needed)
setwd("/home/anirjit/ANIRJIT/RESULTS/LCR_Percov/human")

# Get list of categorized files
files <- list.files(pattern = "_categorized.tsv$")

# Initialize an empty dataframe to store combined data
all_data <- data.frame()

# Loop through files and read data
for (file in files) {
  df <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  
  # Extract file name without extension
  tool_name <- gsub("_categorized.tsv", "", file)
  
  # Add tool name as a column
  df$Tool <- tool_name
  
  # Append data
  all_data <- rbind(all_data, df)
}

# Convert Tool column to a factor (to maintain order)
all_data$Tool <- factor(all_data$Tool, levels = unique(all_data$Tool))

# Create heatmap using ggplot2
p2 <- ggplot(all_data, aes(x = Category, y = Tool, fill = Count)) +
  geom_tile() +  # Heatmap tiles
  scale_fill_gradient(low = "lightyellow2", high = "blue2") +  # Color scale
  labs(x = "LCR Coverage Percentage",
       y = "Methods",
       fill = "LCR Counts") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 16),
        axis.text.x = element_text(angle = 0, hjust = 1, size = 10, colour = "black"),  # Rotate x-axis labels
        axis.text.y = element_text(size = 10, colour = "black"),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        panel.grid.major = element_blank(),  # Remove grid
        panel.grid.minor = element_blank()) +
  scale_y_discrete(labels = c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS\nstrict", "fLPS 2.0", "fLPS 2.0\nstrict", "LCRFinder",
                              "SEG", "SEG\nIntermediate", "SEG\nstrict", "T-REKS", "Xstream"))
dev.off()



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

# Create stacked bar plot
p3 <- ggplot(all_data, aes(x = File, y = Count, fill = Category)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_viridis_d(option = "plasma", name = "LCR Count Categories") +  # Color-blind friendly palette
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 16),
        axis.text.x = element_text(angle = 45, vjust = 1, size = 10, colour = "black"),
        axis.text.y = element_text(angle = 0, vjust = 1, size = 10, colour = "black"),
        axis.title.x = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        panel.grid.major = element_blank(),  # Remove grid
        panel.grid.minor = element_blank()) +
  scale_x_discrete(labels = c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS 2.0", "fLPS 2.0\nstrict", "fLPS\nstrict", "LCRFinder",
                              "SEG", "SEG\nIntermediate", "SEG\nstrict", "T-REKS", "Xstream")) +
  scale_y_continuous(breaks = seq(0, max(all_data$Count), by = 5000)) + 
  labs(x = "Methods",
       y = "Counts") +
  theme(legend.position = "right")



setwd("/home/anirjit/ANIRJIT/RESULTS/Amino_acid/human")

# List all files ending with "_data.txt" (Modify this pattern as needed)
file_list <- list.files(pattern = "*_aa_count")

# Read all files and add a column for dataset name
data_list <- lapply(file_list, function(file) {
  df <- read.table(file, header = TRUE, sep = "\t")
  df$Dataset <- gsub("_aa_count", "", file)  # Extract dataset name
  return(df)
})

# Combine all datasets into one dataframe
merged_data <- bind_rows(data_list)

# Ensure 'Character' is a factor (ordered for better visualization)
merged_data$Character <- factor(merged_data$Character, levels = unique(merged_data$Character))

# Plot stacked bar chart
p4 <- ggplot(merged_data, aes(x = Dataset, y = Proportion, fill = Character)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(x = "Methods",
       y = "Proportion",
       fill = "Amino Acid") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),
    axis.text.x = element_text(angle = 45, vjust = 1, size =10, color = "black"),
    axis.text.y = element_text(angle = 0, vjust = 1, size = 10, color = "black"),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.title.y = element_text(size = 12, face = "bold"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +  
  scale_x_discrete(labels = c("AlcoR\n(Mode 1)","AlcoR\n(Mode 2)","Dotplot","fLPS","fLPS\nstrict","fLPS 2.0","fLPS 2.0\nstrict","LCRFinder",
                              "SEG","SEG\nIntermediate","SEG\nstrict","T-REKS","Xstream")) +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999", "#66C2A5",
                               "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F",  "#E5C494", "#B3B3B3", "#1F78B4", "#33A02C", "#CAB2D6",
                               "#85929E", "#EB984E" ))



# Set working directory
setwd("/home/anirjit/ANIRJIT/RESULTS/Diversity/human")

# List all files ending with "_SNS"
file_list <- list.files(pattern = "*_SNS")

# Read all files into a list of data frames
data_list <- lapply(file_list, read.table, header = TRUE, sep = "\t")

# Extract dataset names dynamically (removing "_SNS" suffix)
dataset_names <- gsub("_SNS", "", file_list)
dataset_labels <- c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS\nstrict", 
                    "fLPS 2.0", "fLPS 2.0\nstrict", "LCRFinder", "SEG\nIntermediate", "SEG", 
                    "SEG\nstrict", "T-REKS", "Xstream")

# Define colors
boxplot_colors <- c("cyan", "lightblue", "violet", "pink", "red", 
                    "brown", "green", "lightgreen", "maroon", "seagreen", 
                    "yellow", "peru", "grey")

# Combine all data into one long dataframe
combined_data <- bind_rows(
  lapply(seq_along(data_list), function(i) {
    df <- data_list[[i]]
    df$Tool <- dataset_labels[i]
    return(df)
  })
)

# Plot for Shannon Entropy
p5 <- ggplot(combined_data, aes(x = Tool, y = Shannon_Entropy, fill = Tool)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(values = boxplot_colors) +
  labs(y = "Shannon Entropy", x = NULL) +
  theme_bw(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = range(combined_data$Shannon_Entropy, na.rm = TRUE))



setwd("/home/anirjit/ANIRJIT/ROC2/human/images")

# Arrange and label the plots
final_plot <- (
  (p1 + p2 + p3) / (p4 + p5)
) + 
  plot_annotation(tag_levels = 'A') & 
  theme(plot.tag = element_text(size = 24, face = "bold"))
# Display the plot
print(final_plot)

# Optionally save it
ggsave("Fig2.jpeg", final_plot, width = 25, height = 20, dpi = 600)
