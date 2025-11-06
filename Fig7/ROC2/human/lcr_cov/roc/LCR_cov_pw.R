# Load necessary libraries
library(ggplot2)
library(dplyr)
library(patchwork)
library(tidyr)

setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_cov/roc")

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

# Ensure Cover_percent is a factor with the desired order
df$Cover_percent <- factor(df$Cover_percent, 
                           levels = c("5", "10", "15", "20", "> 20"),
                           ordered = TRUE)

# Define distinct colors for the tools
tool_colors <- c("red", "blue", "green", "purple", "orange", "skyblue", "magenta", 
                 "yellow", "brown", "pink", "gray", "black", "darkgreen")

p1 <- ggplot(df, aes(x = Cover_percent, y = TPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(x = "LCR Coverage %",
       y = "True Positive Rate (TPR)",
       color = "Tool") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        panel.grid = element_blank(), # Removes the background grid
        axis.line = element_line(color = "black") # Adds x and y axis lines
  )

p2 <- ggplot(df, aes(x = Cover_percent, y = FPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(x = "LCR Coverage %",
       y = "False Positive Rate (FPR)",
       color = "Tool") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 1),
        panel.grid = element_blank(), # Removes the background grid
        axis.line = element_line(color = "black") # Adds x and y axis lines
  )
# Calculate mean TPR and FPR for each Tool
summary_df <- df %>%
  group_by(Tool) %>%
  summarise(
    mean_TPR = mean(TPR, na.rm = TRUE),
    mean_FPR = mean(FPR, na.rm = TRUE)
  )

# Reshape data to long format for grouped bar plot
long_df <- summary_df %>%
  pivot_longer(cols = c(mean_TPR, mean_FPR),
               names_to = "Metric",
               values_to = "Value")

# Rename the metrics for better labels
long_df$Metric <- recode(long_df$Metric,
                         mean_TPR = "Mean TPR",
                         mean_FPR = "Mean FPR")

# Plot grouped bar chart
p3 <- ggplot(long_df, aes(x = reorder(Tool, -Value), y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7)) +
  labs(x = "Tool",
       y = "Rate",
       fill = "Metric") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

jpeg("plots_lcr_cov.jpeg", width = 3000, height = 2000, res = 250, quality = 75)
layout <- (p1 | p2) /      # Top row: p1 and p2 side by side
  p3              # Middle row: p3 full width

layout + plot_layout(heights = c(1, 1))
dev.off()