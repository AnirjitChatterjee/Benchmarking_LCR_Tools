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

# 4) Fixed binning for all panels
bin_x <- 2
bin_y <- 2

df_binned <- df %>%
  mutate(
    x_bin = floor(Mutation_Percent / bin_x) * bin_x,
    y_bin = floor(Most_Frequent_AA_Percent / bin_y) * bin_y
  ) %>%
  group_by(k, x_bin, y_bin) %>%
  summarise(
    n = n(),
    .groups = "drop"
  )

# Ensure panels are ordered by k
df_binned$k <- factor(df_binned$k, levels = sort(unique(df_binned$k)))

# 5) Small multiples plot: same axes, same binning
p_small <- ggplot(df_binned, aes(x = x_bin, y = y_bin, fill = n)) +
  geom_tile() +
  facet_wrap(~ k, ncol = 4) +
  coord_fixed(xlim = c(0, 100), ylim = c(0, 100), expand = FALSE) +
  scale_fill_viridis_c(
    option = "C",
    trans = "sqrt",
    name = "Count"
  ) +
  labs(
    x = "Mutation (%)",
    y = "Most frequent amino acid (%)",
    title = "LC diagram small multiples by consensus tier",
    subtitle = paste0("Bin size: ", bin_x, "% by ", bin_y, "%")
  ) +
  theme_classic() +
  theme(
    legend.position = "right",
    strip.background = element_blank(),
    strip.text = element_text(size = 9)
  )

print(p_small)

# Optional save:
ggsave("LC_small_multiples_by_k.png", p_small, width = 10, height = 8, dpi = 300)
