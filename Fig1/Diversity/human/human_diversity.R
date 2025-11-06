# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra) # for arranging multiple plots

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
plot_shannon <- ggplot(combined_data, aes(x = Tool, y = Shannon_Entropy, fill = Tool)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(values = boxplot_colors) +
  labs(title = expression(bold("Shannon Entropies for") ~ bolditalic("Homo sapiens")),
       y = "Shannon Entropy", x = NULL) +
  theme_bw(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = range(combined_data$Shannon_Entropy, na.rm = TRUE))

# Plot for Simpson Diversity
plot_simpson <- ggplot(combined_data, aes(x = Tool, y = Simpson_Diversity, fill = Tool)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(values = boxplot_colors) +
  labs(title = expression(bold("Simpson Diversity Indices for") ~ bolditalic("Homo sapiens")),
       y = "Simpson's Diversity", x = NULL) +
  theme_bw(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)) +
  coord_cartesian(ylim = range(combined_data$Simpson_Diversity, na.rm = TRUE))

# Arrange side-by-side
grid.arrange(plot_shannon, plot_simpson, ncol = 2)