setwd("/home/anirjit/Downloads/Disprot")
# Load required libraries
library(ggplot2)
library(readr)

# Read the data
df <- read_tsv("human_dp_comp")

# Basic structure check (recommended)
str(df)

jpeg(filename = "Disprot.jpeg", width = 2000, height = 1200, res = 250, quality = 100)
# Dot plot
ggplot(df, aes(
  x = Mutation_Percent,
  y = Most_Frequent_AA_Percent,
  color = Methods
)) +
  geom_point(size = 2.5, alpha = 0.8) +
  scale_color_viridis_d(option = "turbo") +
  scale_x_continuous(limits = c(0, 99)) +
  theme_classic(base_size = 14) +
  labs(
    title = "Scatterplot of Disordered Regions of DisProt",
    x = "Mutation Percent",
    y = "Most Frequent Amino Acid (%)",
    color = "Methods"
  ) +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
dev.off()