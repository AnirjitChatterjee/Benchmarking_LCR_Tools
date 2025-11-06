setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_num/roc")

# Load necessary libraries
library(ggplot2)
library(dplyr)

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

# Convert LCR_num to a factor to ensure all values appear on the x-axis
df$LCR_num <- factor(df$LCR.num, levels = as.character(sort(unique(df$LCR_num))))

# Define distinct colors for the tools
tool_colors <- c("red", "blue", "green", "purple", "orange", "skyblue", "magenta", 
                 "yellow", "brown", "pink", "gray", "black", "darkgreen")

# Save the plot as an image
jpeg("LCR_num_TPR.jpg", width = 5000, height = 4000, res = 750)

# Plot line graph for all tools across LCR_num categories
ggplot(df, aes(x = LCR.num, y = TPR, color = Tool, group = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  scale_color_manual(values = tool_colors) + 
  labs(title = "Effect of number of LCRs on TPR of Methods",
       x = "LCR Number",
       y = "True Positive Rate (TPR)",
       color = "Tool") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5),  # Ensure all labels are shown
        panel.grid = element_blank(), # Remove background grid
        axis.line = element_line(color = "black")) # Add x and y axis lines

dev.off()