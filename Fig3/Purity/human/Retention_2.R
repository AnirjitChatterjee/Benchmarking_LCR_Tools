setwd("/home/anirjit/ANIRJIT/RESULTS/Purity/human")

library(ggplot2)
library(dplyr)
library(Polychrome)  # For creating distinct colors

# Load the data
data <- read.table("entity_counts.tsv", header=TRUE, sep="\t", stringsAsFactors=FALSE)

# Calculate slopes for each tool
slopes <- data %>%
  group_by(Filename) %>%
  summarize(Slope = coef(lm(Proportion ~ Purity, data = .))[2])

# Print slopes
print(slopes)

# Create a color palette with as many colors as unique Filenames
num_files <- length(unique(data$Filename))
distinct_colors <- createPalette(num_files, seedcolors = c("#000000", "#FFFFFF"))
names(distinct_colors) <- unique(data$Filename)

# Plot without grid lines
jpeg("Retention_2.jpg", width = 1500, height = 1200, res = 250, quality = 100)

ggplot(data, aes(x = Purity, y = Proportion, color = Filename, group = Filename)) +
  geom_line(size = 1) +
  geom_point() +
  scale_color_manual(values = distinct_colors) +
  labs(title = "Effect of Purity on Proportion of Retained Entities",
       x = "Purity Level",
       y = "Proportion of Entities Retained",
       color = "Tool") +
  theme_minimal() +
  theme(legend.position = "right")

dev.off()
