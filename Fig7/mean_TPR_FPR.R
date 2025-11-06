# Load necessary libraries
library(ggplot2)
library(dplyr)
library(patchwork)
library(tidyr)

# Define a common theme for all plots
common_theme <- theme_minimal() +
  theme(
    axis.text.x = element_text(size = 12, angle = 45, hjust = 1),
    axis.text.y = element_text(size = 12),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 16),
    panel.grid = element_blank(),
    axis.line = element_line(color = "black")
  )

setwd("/home/anirjit/ANIRJIT/ROC2/human/gene_length/roc")

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

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
p1 <- ggplot(long_df, aes(x = reorder(Tool, -Value), y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7)) +
  labs(title = "Effect of gene length",
       x = "Tool",
       y = "Rate",
       fill = "Metric") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  common_theme


setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_num/roc")

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

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
p2 <- ggplot(long_df, aes(x = reorder(Tool, -Value), y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7)) +
  labs(title = "Effect of number of LCRs per gene",
       x = "Tool",
       y = "Rate",
       fill = "Metric") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  common_theme


setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_cov/roc")

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

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
  labs(title = "Effect of LCR coverage %",
       x = "Tool",
       y = "Rate",
       fill = "Metric") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  common_theme


setwd("/home/anirjit/ANIRJIT/ROC2/human/entropy/roc")

# Read the data
df <- read.delim("all.tsv", header = TRUE, sep = "\t")

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
p4 <- ggplot(long_df, aes(x = reorder(Tool, -Value), y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7)) +
  labs(title = "Effect of LCR:Gene Entropy Ratio",
       x = "Tool",
       y = "Rate",
       fill = "Metric") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  common_theme


setwd("/home/anirjit/ANIRJIT/ROC2/human/images")

# Arrange and label the plots
final_plot <- (
  (p1 + p2) / (p3 + p4)
) + 
  plot_annotation(tag_levels = 'A') & 
  theme(plot.tag = element_text(size = 24, face = "bold"))
# Display the plot
print(final_plot)

# Optionally save it
ggsave("mean_TPR_FPR.jpeg", final_plot, width = 20, height = 16, dpi = 600)
