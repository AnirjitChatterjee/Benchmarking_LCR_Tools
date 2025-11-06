library(ggplot2)
library(ggpattern)
library(dplyr)
library(Polychrome)
library(patchwork)


setwd("/home/anirjit/ANIRJIT/RESULTS/multiinter")

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

p1 <- ggplot(data, aes(x = No..of.Tools, y = Proportion, fill = Best.Peptide, pattern = Pattern)) +
  geom_bar_pattern(stat = "identity",
                   pattern_color = "black",
                   pattern_fill = "black",
                   pattern_density = 0.02,
                   pattern_spacing = 0.01,
                   pattern_size = 0.2) +
  scale_fill_manual(values = distinct_colors) +
  scale_pattern_manual(values = c("none" = "none", "stripe" = "stripe", "crosshatch" = "crosshatch"),
                       labels = c("none" = "Monopeptide", "stripe" = "Dipeptide", "crosshatch" = "Tripeptide")) +
  labs(x = "Regions shared by n Number of methods",
       y = "Proportion",
       fill = "Peptide Motif",
       pattern = "Peptide Type") +
  theme_minimal() +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(size = 14),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    legend.key.size = unit(1, "cm")
  ) +
  guides(
    fill = guide_legend(override.aes = list(pattern = "none")),
    pattern = guide_legend(override.aes = list(fill = "white"))
  )



# Define Okabe-Ito color-blind friendly palette with 13 distinct colors
okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7", "#999999",
               "#AD7700", "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3")

# Set working directory
setwd("/home/anirjit/ANIRJIT/RESULTS/multiinter")

# Get all files ending with "_entropy_purity.tsv"
file_list <- list.files(pattern = "[0-9]+_gf_entropy_purity.tsv")

# Extract numeric prefixes for sorting
numeric_prefix <- as.numeric(gsub("_.*", "", file_list))
file_list <- file_list[order(numeric_prefix)]
numeric_prefix <- numeric_prefix[order(numeric_prefix)]  # Ensure consistent order

# Initialize an empty data frame to collect entropy values
entropy_df <- data.frame(Group = character(), Entropy = numeric())

# Read and combine entropy values into one data frame
for (i in seq_along(file_list)) {
  file <- file_list[i]
  prefix <- numeric_prefix[i]
  df <- read.table(file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  temp_df <- data.frame(Group = as.factor(prefix), Entropy = df$Entropy)
  entropy_df <- rbind(entropy_df, temp_df)
}

# Convert Group to ordered factor
entropy_df$Group <- factor(entropy_df$Group, levels = sort(unique(entropy_df$Group)))

# Plot using ggplot2
p2 <- ggplot(entropy_df, aes(x = Group, y = Entropy, fill = Group)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(values = okabe_ito[1:length(unique(entropy_df$Group))]) +
  labs(
    x = "Regions shared by n Number of methods",
    y = "Shannon's Entropy"
  ) +
  theme_minimal() +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18),
    legend.position = "none"
  )



# Set working directory
setwd("/home/anirjit/ANIRJIT/RESULTS/multiinter")

# Get all files ending with "_entropy_purity.tsv"
file_list <- list.files(pattern = "[0-9]+_gf_entropy_purity.tsv")

# Extract numeric prefixes and sort based on them
numeric_prefix <- as.numeric(gsub("_.*", "", file_list))
file_list <- file_list[order(numeric_prefix)]
numeric_prefix <- numeric_prefix[order(numeric_prefix)]

# Initialize an empty data frame for purity values
purity_df <- data.frame(Group = character(), Purity = numeric())

# Read each file and collect purity values
for (i in seq_along(file_list)) {
  file <- file_list[i]
  prefix <- numeric_prefix[i]
  df <- read.table(file, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  
  temp_df <- data.frame(Group = as.factor(prefix), Purity = df$Purity)
  purity_df <- rbind(purity_df, temp_df)
}

# Ensure Group is an ordered factor
purity_df$Group <- factor(purity_df$Group, levels = sort(unique(purity_df$Group)))

# Plot with ggplot2
p3 <- ggplot(purity_df, aes(x = Group, y = Purity, fill = Group)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(values = okabe_ito[1:length(unique(purity_df$Group))]) +
  labs(
    x = "Regions shared by n Number of methods",
    y = "Purity"
  ) +
  theme_minimal() +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    axis.title.x = element_text(size = 18),
    axis.title.y = element_text(size = 18),
    legend.position = "none"
  )



setwd("/home/anirjit/ANIRJIT/ROC2/human/images")

final_plot <- (
  p1 | (p2 / p3)
) + 
  plot_annotation(tag_levels = 'A') & 
  theme(plot.tag = element_text(size = 24, face = "bold"))

# Optionally save it
ggsave("Fig2.jpeg", final_plot, width = 25, height = 20, dpi = 600)
