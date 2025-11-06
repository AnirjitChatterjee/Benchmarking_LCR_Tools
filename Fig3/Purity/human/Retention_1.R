setwd("/home/anirjit/ANIRJIT/RESULTS/Purity/human")

library(ggplot2)
library(dplyr)

# Load the data
data <- read.table("entity_counts.tsv", header=TRUE, sep="\t", stringsAsFactors=FALSE)

# Convert Filename to factor for better grouping
data$Filename <- factor(data$Filename, levels = unique(data$Filename))

# Define custom colors for files
custom_colors <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", 
                   "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")
jpeg("Retention_1.jpg", width = 1500, height = 1200, res = 250, quality = 100)
# Plot
ggplot(data, aes(x = Filename, y = Proportion, fill = as.factor(Purity))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Proportion of Entities Retained per Tool at Different Purities",
       x = "Tool",
       y = "Proportion of Entities Retained",
       fill = "Purity Level") +
  scale_fill_manual(values = custom_colors) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotates labels for readability
dev.off()