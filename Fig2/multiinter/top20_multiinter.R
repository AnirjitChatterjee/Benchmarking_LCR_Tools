setwd("/home/anirjit/ANIRJIT/RESULTS/multiinter")

library(ggplot2)
library(ggpattern)
library(dplyr)
library(Polychrome)

# Read data
data <- read.delim("top_20.csv", header = TRUE, sep = "\t")

# Convert columns to factors
data$No..of.Tools <- factor(data$No..of.Tools)

# Assign peptide types
data$Peptide_Type <- case_when(
  grepl("^[A-Z]$", data$Best.Peptide) ~ "Mono",
  grepl("^[A-Z]{2}$", data$Best.Peptide) ~ "Di",
  grepl("^[A-Z]{3}$", data$Best.Peptide) ~ "Tri",
  TRUE ~ "Other"
)

# Ensure "Remaining" is last in order
unique_peptides <- unique(data$Best.Peptide)
ordered_peptides <- c(setdiff(unique_peptides, "Remaining"), "Remaining")
data$Best.Peptide <- factor(data$Best.Peptide, levels = ordered_peptides)

# Generate colors
num_peptides <- length(levels(data$Best.Peptide))
distinct_colors <- createPalette(num_peptides, seedcolors = c("#000000", "#FFFFFF"))
names(distinct_colors) <- levels(data$Best.Peptide)  # Safe mapping

# Define patterns
data$Pattern <- factor(case_when(
  data$Peptide_Type == "Mono" ~ "none",
  data$Peptide_Type == "Di" ~ "stripe",
  data$Peptide_Type == "Tri" ~ "crosshatch",
  TRUE ~ "none"
), levels = c("none", "stripe", "crosshatch"))

# Output plot
jpeg(filename = "top20_multiinter.jpg", width = 2500, height = 2000, res = 250, quality = 50)

ggplot(data, aes(x = No..of.Tools, y = Proportion, fill = Best.Peptide, pattern = Pattern)) +
  geom_bar_pattern(stat = "identity",
                   pattern_color = "black",
                   pattern_fill = "black",
                   pattern_density = 0.02,
                   pattern_spacing = 0.01,
                   pattern_size = 0.2) +
  scale_fill_manual(values = distinct_colors) +
  scale_pattern_manual(values = c("none" = "none", "stripe" = "stripe", "crosshatch" = "crosshatch"),
                       labels = c("none" = "Monopeptide", "stripe" = "Dipeptide", "crosshatch" = "Tripeptide")) +
  labs(title = "Most common peptides detected in LCRs across intersections of various tools",
       x = "Number of Tools",
       y = "Proportion",
       fill = "Peptide",
       pattern = "Peptide Type") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  guides(
    fill = guide_legend(override.aes = list(pattern = "none")),
    pattern = guide_legend(override.aes = list(fill = "white"))
  )

dev.off()
