library(ggplot2)
library(tidyr)
library(dplyr)
library(Polychrome)  # For creating distinct colors

setwd("/home/anirjit/ANIRJIT/RESULTS/Purity/human")

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

setwd("/home/anirjit/ANIRJIT/ROC2/human/images")

p1 <- ggplot(data, aes(x = Purity, y = Proportion, color = Filename, group = Filename)) +
  geom_line(size = 2) +
  geom_point(size = 3) +
  scale_color_manual(values = distinct_colors) +
  labs(x = "Purity Level",
       y = "Proportion of Entities Retained",
       color = "Methods") +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    legend.title = element_text(size = 20),
    legend.text = element_text(size = 16),
    legend.key.size = unit(1.5, "cm")
    )

# Optionally save it
ggsave("Fig3.jpeg", p1, width = 20, height = 16, dpi = 600)
