# Load packages
library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(ggplot2)

# 1) Find files like "1_complexity", "2_complexity", ...
files <- list.files(
  path = ".",
  pattern = "^[0-9]+_complexity(\\.[A-Za-z0-9]+)?$",
  full.names = TRUE
)
stopifnot(length(files) > 0)

# Extract k from filename
get_k <- function(f) {
  m <- stringr::str_match(basename(f), "^([0-9]+)_complexity")
  as.integer(m[, 2])
}

# 2) Read and combine
df <- purrr::map_dfr(files, function(f) {
  k <- get_k(f)
  readr::read_tsv(f, col_types = readr::cols(.default = readr::col_guess())) %>%
    dplyr::mutate(k = k)
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
    is.finite(Most_Frequent_AA_Percent),
    is.finite(k)
  )

# 4) Bin the LC diagram
# Adjust binwidths as needed; 2% is a good starting point.
bin_x <- 2
bin_y <- 2

df_bins <- df %>%
  mutate(
    x_bin = floor(Mutation_Percent / bin_x) * bin_x,
    y_bin = floor(Most_Frequent_AA_Percent / bin_y) * bin_y
  ) %>%
  group_by(x_bin, y_bin) %>%
  summarise(
    k_max = max(k, na.rm = TRUE),   # highest consensus tier present in this bin
    n_points = n(),                # how many points landed here (all tiers combined)
    .groups = "drop"
  )

# 5) Plot occupancy map: color = highest k present in each bin
# Use coord_fixed so bins look square (LC diagram style)
p_occ <- ggplot(df_bins, aes(x = x_bin, y = y_bin, fill = k_max)) +
  geom_tile() +
  coord_fixed(xlim = c(0, 100), ylim = c(0, 100), expand = FALSE) +
  scale_fill_viridis_c(
    option = "C",
    direction = 1,
    name = "Max k in bin"
  ) +
  labs(
    x = "Mutation (%)",
    y = "Most frequent amino acid (%)",
    title = "Consensus occupancy map (cumulative overlays)",
    subtitle = paste0("Bin size: ", bin_x, "% by ", bin_y, "%")
  ) +
  theme_classic() +
  theme(
    legend.position = "right"
  )

print(p_occ)

# Optional save:
ggsave("LC_consensus_occupancy_map.png", p_occ, width = 7, height = 6, dpi = 300)
