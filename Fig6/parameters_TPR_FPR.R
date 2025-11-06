# Load necessary libraries
library(ggplot2)
library(dplyr)
library(patchwork)
library(tidyr)
library(cowplot)
library(readr)

# Define a common theme for all plots
common_theme <- theme_minimal() +
  theme(
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 16),
    panel.grid = element_blank(),
    axis.line = element_line(color = "black")
  )

# ----------------------- Gene Length -----------------------
setwd("/home/anirjit/ANIRJIT/ROC2/human/gene_length/roc")
df <- read.delim("all.tsv", header = TRUE, sep = "\t")
df$Category <- factor(df$Category, levels = as.character(1:10))
tool_colors <- c("red", "blue", "green", "purple", "orange", "skyblue", "magenta", 
                 "yellow", "brown", "pink", "gray", "black", "darkgreen")

p1 <- ggplot(df, aes(x = Category, y = TPR, color = Tool, group = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  scale_color_manual(values = tool_colors) +
  labs(x = "Gene Length Categories", y = "True Positive Rate (TPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  common_theme

p2 <- ggplot(df, aes(x = Category, y = FPR, color = Tool, group = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  scale_color_manual(values = tool_colors) +
  labs(x = "Gene Length Categories", y = "False Positive Rate (FPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  common_theme

# ----------------------- LCR Number -----------------------
setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_num/roc")
df <- read.delim("all.tsv", header = TRUE, sep = "\t")
df$LCR.num <- factor(df$LCR.num, levels = as.character(sort(unique(df$LCR.num))))

p3 <- ggplot(df, aes(x = LCR.num, y = TPR, color = Tool, group = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  scale_color_manual(values = tool_colors) + 
  labs(x = "LCR Number", y = "True Positive Rate (TPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) +
  common_theme

p4 <- ggplot(df, aes(x = LCR.num, y = FPR, color = Tool, group = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  scale_color_manual(values = tool_colors) + 
  labs(x = "LCR Number", y = "False Positive Rate (FPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5)) +
  common_theme

# ----------------------- LCR Coverage -----------------------
setwd("/home/anirjit/ANIRJIT/ROC2/human/lcr_cov/roc")
df <- read.delim("all.tsv", header = TRUE, sep = "\t")
df$Cover_percent <- factor(df$Cover_percent, 
                           levels = c("5", "10", "15", "20", "> 20"),
                           ordered = TRUE)

p5 <- ggplot(df, aes(x = Cover_percent, y = TPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(x = "LCR Coverage %", y = "True Positive Rate (TPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  common_theme

p6 <- ggplot(df, aes(x = Cover_percent, y = FPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(x = "LCR Coverage %", y = "False Positive Rate (FPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  common_theme

# ----------------------- Entropy Ratio -----------------------
setwd("/home/anirjit/ANIRJIT/ROC2/human/entropy/roc")
df <- read_tsv("all.tsv")
df$Ratio <- factor(df$Ratio, levels = c("0.2", "0.4", "0.6", "0.8", "1"), ordered = TRUE)

p7 <- ggplot(df, aes(x = Ratio, y = TPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(x = "LCR:Gene Entropy Ratio", y = "True Positive Rate (TPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  common_theme

p8 <- ggplot(df, aes(x = Ratio, y = FPR, group = Tool, color = Tool)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = tool_colors) +
  labs(x = "LCR:Gene Entropy Ratio", y = "False Positive Rate (FPR)", color = "Tool") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  common_theme

# ----------------------- Final Layout -----------------------
setwd("/home/anirjit/ANIRJIT/ROC2/human/images")

groupA <- (p1 | p2) 
groupB <- (p3 | p4) 
groupC <- (p5 | p6) 
groupD <- (p7 | p8) 

row1 <- wrap_elements(groupA) | wrap_elements(groupB)
row2 <- wrap_elements(groupC) | wrap_elements(groupD)

layout <- (row1 / row2) + plot_annotation(tag_levels = "A")

# Display and save
layout
ggsave("parameters_TPR_FPR.jpeg", layout, width = 25, height = 20, dpi = 600)
