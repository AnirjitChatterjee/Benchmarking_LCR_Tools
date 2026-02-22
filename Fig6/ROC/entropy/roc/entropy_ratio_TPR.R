setwd("/home/anirjit/ANIRJIT/ROC2/human/entropy/roc")

library(ggplot2)
library(dplyr)
library(readr)

# Load the dataset
df <- read_tsv("all.tsv")

# Ensure Ratio is a factor with the desired order
df$Ratio <- factor(df$Ratio, 
                           levels = c("0.2", "0.4", "0.6", "0.8", "1"),
                           ordered = TRUE)

# Define distinct colors for the tools
tool_colors <- c("red", "blue", "green", "purple", "orange", "skyblue", "magenta", 
                 "yellow", "brown", "pink", "gray", "black", "darkgreen")

jpeg("entropy_ratio_FPR.jpg", width = 5000, height = 4000, res = 750)
# Plot FPR vs Ratio for each tool
ggplot(df, aes(x = Ratio, y = FPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(title = "Effect of LCR:Gene Entropy Ratio on FPR of Methods",
       x = "LCR:Gene Entropy Ratio",
       y = "False Positive Rate (FPR)",
       color = "Tool") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        panel.grid = element_blank(), # Removes the background grid
        axis.line = element_line(color = "black") # Adds x and y axis lines
  )
dev.off()
