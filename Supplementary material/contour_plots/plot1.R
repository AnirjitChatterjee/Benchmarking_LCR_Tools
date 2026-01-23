# Load packages
library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(ggplot2)

# Okabe–Ito–style extended palette (13 distinct, non-repeating colors)
okabe_ito <- c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442",
  "#0072B2", "#D55E00", "#CC79A7", "#999999",
  "#AD7700", "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3"
)

# 1) Find files like "1_complexity", "2_complexity", ...
files <- list.files(
  path = ".",
  pattern = "^[0-9]+_complexity(\\.[A-Za-z0-9]+)?$",
  full.names = TRUE
)

stopifnot(length(files) > 0)

# Extract k from filename
get_k <- function(f) as.integer(str_match(basename(f), "^([0-9]+)_complexity")[, 2])

# 2) Read and combine
df <- map_dfr(files, function(f) {
  k <- get_k(f)
  read_tsv(f, col_types = cols(.default = col_guess())) %>%
    mutate(k = k)
})

# 3) Ensure numeric columns and clean
df <- df %>%
  mutate(
    Mutation_Percent = as.numeric(Mutation_Percent),
    Most_Frequent_AA_Percent = as.numeric(Most_Frequent_AA_Percent),
    k = as.integer(k)
  ) %>%
  filter(
    is.finite(Mutation_Percent),
    is.finite(Most_Frequent_AA_Percent)
  )

# Ensure we have enough colors and map one-to-one with k
k_levels <- sort(unique(df$k))
stopifnot(length(k_levels) <= length(okabe_ito))
palette <- okabe_ito[seq_along(k_levels)]
names(palette) <- as.character(k_levels)

# 4) Plot: overlaid 2D density contours with distinct colors
p <- ggplot(df, aes(x = Mutation_Percent, y = Most_Frequent_AA_Percent)) +
  stat_density_2d(
    aes(colour = factor(k), linewidth = k),
    geom = "density_2d",
    bins = 6,
    contour_var = "ndensity"
  ) +
  scale_colour_manual(
    values = palette,
    breaks = as.character(k_levels),
    name = "k (methods)"
  ) +
  scale_linewidth(range = c(0.25, 1.3), guide = "none") +
  coord_cartesian(xlim = c(0, 100), ylim = c(0, 100), expand = FALSE) +
  labs(
    x = "Mutation (%)",
    y = "Most frequent amino acid (%)"
  ) +
  theme_classic() +
  theme(
    legend.position = "right",
    legend.key.height = unit(0.6, "cm")
  )

print(p)

# Optional save
ggsave("LC_diagram_density_contours_okabe_ito.png", p, width = 7, height = 6, dpi = 300)
