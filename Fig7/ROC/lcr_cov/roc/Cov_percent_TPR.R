setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_cov/roc")

library(ggplot2)
library(dplyr)
library(readr)

# Load the dataset
df <- read_tsv("all.tsv")

# Ensure Cover_percent is a factor with the desired order
df$Cover_percent <- factor(df$Cover_percent, 
                           levels = c("5", "10", "15", "20", "> 20"),
                           ordered = TRUE)

# Define distinct colors for the tools
tool_colors <- c("red", "blue", "green", "purple", "orange", "skyblue", "magenta", 
                 "yellow", "brown", "pink", "gray", "black", "darkgreen")

jpeg("Cov_percent_TPR.jpg", width = 5000, height = 4000, res = 750)
# Plot TPR vs Cover_percent for each tool
ggplot(df, aes(x = Cover_percent, y = TPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(title = "Effect of LCR Coverage on TPR of Methods",
       x = "LCR Coverage %",
       y = "True Positive Rate (TPR)",
       color = "Tool") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        panel.grid = element_blank(), # Removes the background grid
        axis.line = element_line(color = "black") # Adds x and y axis lines
  )
dev.off()
