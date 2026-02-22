setwd("/home/anirjit/ANIRJIT/ROC2/human/gene_length/roc")

# Load necessary libraries
library(ggplot2)
library(dplyr)

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

# Define distinct colors for the tools
tool_colors <- c("red", "blue", "green", "purple", "orange", "skyblue", "magenta", 
                 "yellow", "brown", "pink", "gray", "black", "darkgreen")

# Ensure Category is a factor with levels 1 to 10
df$Category <- factor(df$Category, levels = as.character(1:10))

jpeg("gene_length_TPR.jpg", width = 5000, height = 4000, res = 750)
ggplot(df, aes(x = Category, y = TPR, color = Tool, group = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  scale_color_manual(values = tool_colors) +
  scale_x_discrete(drop = FALSE) +  # ensures all factor levels are shown, even if some are missing
  labs(title = "Effect of gene length on TPR of Methods",
       x = "Gene Length Categories",
       y = "True Positive Rate (TPR)",
       color = "Tool") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        panel.grid = element_blank(),
        axis.line = element_line(color = "black"))
dev.off()
