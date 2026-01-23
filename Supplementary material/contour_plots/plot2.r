# Load packages
library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(ggplot2)

# Distinct palette (13 colors)
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
get_k <- function(f) {
  m <- str_match(basename(f), "^([0-9]+)_complexity")
  as.integer(m[, 2])
}

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
    is.finite(Most_Frequent_AA_Percent),
    is.finite(k)
  )

# 4) Summarise per k: centroid (median) + spread (IQR)
sum_k <- df %>%
  group_by(k) %>%
  summarise(
    x_med = median(Mutation_Percent, na.rm = TRUE),
    y_med = median(Most_Frequent_AA_Percent, na.rm = TRUE),
    x_q25 = quantile(Mutation_Percent, 0.25, na.rm = TRUE),
    x_q75 = quantile(Mutation_Percent, 0.75, na.rm = TRUE),
    y_q25 = quantile(Most_Frequent_AA_Percent, 0.25, na.rm = TRUE),
    y_q75 = quantile(Most_Frequent_AA_Percent, 0.75, na.rm = TRUE),
    n = dplyr::n(),
    .groups = "drop"
  ) %>%
  arrange(k)

# 5) Map colors one-to-one with k
k_levels <- sum_k$k
stopifnot(length(k_levels) <= length(okabe_ito))
pal <- okabe_ito[seq_along(k_levels)]
names(pal) <- as.character(k_levels)

# 6) Add next-point columns for arrows (flow direction: increasing k)
sum_k <- sum_k %>%
  mutate(
    x_next = dplyr::lead(x_med),
    y_next = dplyr::lead(y_med)
  )

# 7) Plot: centroid flow with IQR crossbars and arrows
p_flow <- ggplot(sum_k, aes(x = x_med, y = y_med, colour = factor(k))) +
  # IQR crossbars
  geom_segment(aes(x = x_q25, xend = x_q75, y = y_med, yend = y_med),
               linewidth = 0.7, alpha = 0.9) +
  geom_segment(aes(x = x_med, xend = x_med, y = y_q25, yend = y_q75),
               linewidth = 0.7, alpha = 0.9) +
  # Arrows between successive k medians
  geom_segment(
    data = sum_k %>% filter(is.finite(x_next), is.finite(y_next)),
    aes(x = x_med, y = y_med, xend = x_next, yend = y_next),
    linewidth = 0.6,
    alpha = 0.8,
    arrow = grid::arrow(length = grid::unit(0.18, "cm"))
  ) +
  geom_point(size = 3) +
  geom_text(aes(label = k), nudge_y = 1.2, show.legend = FALSE, size = 3) +
  scale_colour_manual(values = pal, breaks = as.character(k_levels), name = "k (methods)") +
  coord_cartesian(xlim = c(0, 100), ylim = c(0, 100), expand = FALSE) +
  labs(
    x = "Mutation (%)",
    y = "Most frequent amino acid (%)",
    title = "Centroid flow across consensus tiers (median and IQR)"
  ) +
  theme_classic() +
  theme(
    legend.position = "right",
    legend.key.height = grid::unit(0.6, "cm")
  )

print(p_flow)

# Optional save:
ggsave("LC_centroid_flow_median_IQR.png", p_flow, width = 7, height = 6, dpi = 300)
