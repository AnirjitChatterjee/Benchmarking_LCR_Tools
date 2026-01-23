setwd("/home/anirjit/ANIRJIT/images_R1/multi_complexity/multi_complexity")
library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)
library(tibble)
library(ggplot2)

set.seed(1)

# ----------------------------
# Paths
# ----------------------------
lcr_dir <- "contour_plots"
bg_file <- file.path("Disprot", "Disprot_complexity")

stopifnot(dir.exists(lcr_dir))
stopifnot(file.exists(bg_file))

out_dir <- "boundary_outputs"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ----------------------------
# Parameters
# ----------------------------
bin_x <- 2
bin_y <- 2
a <- 1
test_frac <- 0.25
max_test_per_class <- 200000  # set Inf for no cap
k_min_list <- c(13, 12, 11, 10, 9, 8, 7)

# Small nudge to avoid contouring exactly on a very common grid value
contour_eps <- 1e-6

# ----------------------------
# Helpers
# ----------------------------
get_k <- function(f) {
  m <- str_match(basename(f), "^([0-9]+)_complexity")
  as.integer(m[, 2])
}

as_numeric_cols <- function(dat) {
  dat %>%
    mutate(
      Mutation_Percent = as.numeric(Mutation_Percent),
      Most_Frequent_AA_Percent = as.numeric(Most_Frequent_AA_Percent)
    ) %>%
    filter(is.finite(Mutation_Percent), is.finite(Most_Frequent_AA_Percent))
}

bin_xy <- function(dat) {
  dat %>%
    mutate(
      x_bin = floor(Mutation_Percent / bin_x) * bin_x,
      y_bin = floor(Most_Frequent_AA_Percent / bin_y) * bin_y
    )
}

build_posterior_grid <- function(pos_train, neg_train, fill_mode = c("prior", "mean")) {
  fill_mode <- match.arg(fill_mode)

  pos_b <- bin_xy(pos_train) %>% count(x_bin, y_bin, name = "n_lcr")
  neg_b <- bin_xy(neg_train) %>% count(x_bin, y_bin, name = "n_bg")

  grid <- full_join(pos_b, neg_b, by = c("x_bin", "y_bin")) %>%
    mutate(
      n_lcr = ifelse(is.na(n_lcr), 0, n_lcr),
      n_bg  = ifelse(is.na(n_bg), 0, n_bg),
      n_tot = n_lcr + n_bg,
      p_lcr = ifelse(n_tot > 0, (n_lcr + a) / (n_tot + 2 * a), NA_real_)
    )

  x_vals <- seq(0, 100, by = bin_x)
  y_vals <- seq(0, 100, by = bin_y)

  grid_complete <- grid %>%
    select(x_bin, y_bin, p_lcr) %>%
    complete(x_bin = x_vals, y_bin = y_vals)

  if (fill_mode == "mean") {
    fill_value <- mean(grid$p_lcr, na.rm = TRUE)
  } else {
    fill_value <- (nrow(pos_train) + a) / (nrow(pos_train) + nrow(neg_train) + 2 * a)
  }

  grid_complete$p_lcr_filled <- ifelse(is.na(grid_complete$p_lcr), fill_value, grid_complete$p_lcr)

  list(grid = grid_complete, x_vals = x_vals, y_vals = y_vals, fill_value = fill_value)
}

score_points <- function(dat, grid_complete) {
  dat_b <- bin_xy(dat) %>% select(x_bin, y_bin)
  scored <- dat_b %>%
    left_join(grid_complete %>% select(x_bin, y_bin, p_lcr_filled), by = c("x_bin", "y_bin"))
  scored$p_lcr_filled
}

roc_youden <- function(scores, labels) {
  ok <- is.finite(scores) & (labels %in% c(0, 1))
  scores <- scores[ok]
  labels <- labels[ok]

  P <- sum(labels == 1)
  N <- sum(labels == 0)
  if (P == 0 || N == 0) stop("Need both classes for ROC.")

  thr <- sort(unique(scores))
  thr <- c(-Inf, thr, Inf)

  tpr <- numeric(length(thr))
  fpr <- numeric(length(thr))

  for (i in seq_along(thr)) {
    pred_pos <- scores >= thr[i]
    tp <- sum(pred_pos & labels == 1)
    fp <- sum(pred_pos & labels == 0)
    tpr[i] <- tp / P
    fpr[i] <- fp / N
  }

  J <- tpr - fpr
  best_idx <- which(J == max(J, na.rm = TRUE))
  best_idx <- best_idx[length(best_idx)]

  ord <- order(fpr, tpr)
  auc <- sum(diff(fpr[ord]) * (tpr[ord][-1] + tpr[ord][-length(tpr[ord])]) / 2)

  list(
    best_threshold = thr[best_idx],
    best_tpr = tpr[best_idx],
    best_fpr = fpr[best_idx],
    best_J = J[best_idx],
    auc = auc
  )
}

# Extract boundary using ggplot's contour stat and ggplot_build()
# Returns a tibble with x, y, piece_id, pt_idx, n_pts, level_used
extract_boundary_from_ggplot <- function(grid_complete, level, eps = 1e-6) {
  # ggplot contour expects a long table with z
  gdat <- grid_complete %>%
    transmute(x = x_bin, y = y_bin, z = p_lcr_filled) %>%
    filter(is.finite(z))

  # try level, then nudges
  levels_try <- unique(c(level, level + eps, level - eps))
  levels_try <- levels_try[is.finite(levels_try)]

  for (lv in levels_try) {
    p <- ggplot(gdat, aes(x = x, y = y, z = z)) +
      stat_contour(breaks = lv)

    built <- ggplot_build(p)
    if (length(built$data) < 1) next
    d <- built$data[[1]]

    # d typically has x, y, group, level, piece (varies by ggplot2 version)
    if (!all(c("x", "y", "group") %in% names(d))) next

    pts <- d %>%
      transmute(
        x = x,
        y = y,
        piece_id = as.integer(group),
        level_used = lv
      ) %>%
      group_by(piece_id) %>%
      mutate(
        pt_idx = row_number(),
        n_pts = n()
      ) %>%
      ungroup() %>%
      filter(n_pts >= 2)

    if (nrow(pts) > 0) return(pts)
  }

  tibble()
}

# ----------------------------
# Read data once
# ----------------------------
lcr_files <- list.files(
  path = lcr_dir,
  pattern = "^[0-9]+_complexity(\\.[A-Za-z0-9]+)?$",
  full.names = TRUE
)
stopifnot(length(lcr_files) > 0)

lcr <- map_dfr(lcr_files, function(f) {
  k <- get_k(f)
  read_tsv(f, col_types = cols(.default = col_guess())) %>%
    mutate(k = k)
}) %>%
  mutate(k = as.integer(k)) %>%
  as_numeric_cols() %>%
  filter(is.finite(k))

neg_all <- read_tsv(bg_file, col_types = cols(.default = col_guess())) %>%
  as_numeric_cols()

stopifnot(nrow(neg_all) > 0)

# ----------------------------
# Loop over k_min values
# ----------------------------
results <- list()

for (k_min in k_min_list) {
  message("---- k_min = ", k_min, " ----")

  pos_all <- lcr %>% filter(k >= k_min)
  if (nrow(pos_all) < 50) {
    message("Skipping k_min=", k_min, " (too few positives: ", nrow(pos_all), ")")
    next
  }

  # Train/test split
  pos_n <- nrow(pos_all)
  neg_n <- nrow(neg_all)

  pos_test_idx <- sample.int(pos_n, size = floor(test_frac * pos_n))
  neg_test_idx <- sample.int(neg_n, size = floor(test_frac * neg_n))

  pos_test <- pos_all[pos_test_idx, , drop = FALSE]
  pos_train <- pos_all[-pos_test_idx, , drop = FALSE]
  neg_test <- neg_all[neg_test_idx, , drop = FALSE]
  neg_train <- neg_all[-neg_test_idx, , drop = FALSE]

  if (is.finite(max_test_per_class)) {
    if (nrow(pos_test) > max_test_per_class) pos_test <- pos_test %>% slice_sample(n = max_test_per_class)
    if (nrow(neg_test) > max_test_per_class) neg_test <- neg_test %>% slice_sample(n = max_test_per_class)
  }

  # Posterior grid
  posterior_obj <- build_posterior_grid(pos_train, neg_train, fill_mode = "prior")
  grid_complete <- posterior_obj$grid

  # Held-out scoring + ROC
  pos_scores <- score_points(pos_test, grid_complete)
  neg_scores <- score_points(neg_test, grid_complete)

  scores <- c(pos_scores, neg_scores)
  labels <- c(rep(1L, length(pos_scores)), rep(0L, length(neg_scores)))

  roc_res <- roc_youden(scores, labels)
  p_thresh <- roc_res$best_threshold
  auc_val <- roc_res$auc

  message(
    "AUC=", sprintf("%.3f", auc_val),
    " | p_thresh=", sprintf("%.6f", p_thresh),
    " | TPR=", sprintf("%.3f", roc_res$best_tpr),
    " | FPR=", sprintf("%.3f", roc_res$best_fpr)
  )

  # Extract boundary via ggplot contour build
  boundary_points <- extract_boundary_from_ggplot(grid_complete, p_thresh, eps = contour_eps)

  message(
    "Boundary extraction=ggplot_stat_contour",
    " | n_points=", nrow(boundary_points),
    " | n_pieces=", if (nrow(boundary_points) > 0) dplyr::n_distinct(boundary_points$piece_id) else 0
  )

  if (nrow(boundary_points) == 0) {
    message(
      "No usable boundary pieces found for k_min=", k_min,
      " at p_thresh=", sprintf("%.6f", p_thresh),
      " using ggplot contour extraction."
    )
    next
  }

  # Split into 2-point segments vs 3+ point paths
  boundary_segs <- boundary_points %>%
    filter(n_pts == 2) %>%
    arrange(piece_id, pt_idx) %>%
    group_by(piece_id) %>%
    summarise(
      x = first(x), y = first(y),
      xend = last(x), yend = last(y),
      .groups = "drop"
    )

  boundary_paths <- boundary_points %>%
    filter(n_pts >= 3) %>%
    arrange(piece_id, pt_idx)

  # Save boundary points
  boundary_tsv <- file.path(out_dir, paste0("LC_boundary_points_kmin_", k_min, ".tsv"))
  write_tsv(boundary_points, boundary_tsv)

  # Plot and save
  plot_grid <- grid_complete %>% select(x_bin, y_bin, p_lcr_filled)

  p_boundary <- ggplot(plot_grid, aes(x = x_bin, y = y_bin)) +
    geom_tile(aes(fill = p_lcr_filled)) +
    geom_segment(
      data = boundary_segs,
      aes(x = x, y = y, xend = xend, yend = yend),
      inherit.aes = FALSE,
      linewidth = 1.0
    ) +
    geom_path(
      data = boundary_paths,
      aes(x = x, y = y, group = piece_id),
      inherit.aes = FALSE,
      linewidth = 1.0
    ) +
    coord_fixed(xlim = c(0, 100), ylim = c(0, 100), expand = FALSE) +
    scale_fill_viridis_c(option = "C", name = "P(LCR | bin)") +
    labs(
      x = "Mutation (%)",
      y = "Most frequent amino acid (%)",
      title = "LC posterior map with ROC-optimized boundary",
      subtitle = paste0(
        "k_min=", k_min,
        " | bins: ", bin_x, "% by ", bin_y,
        "% | Laplace a=", a,
        " | held-out AUC=", sprintf("%.3f", auc_val),
        " | p_thresh=", sprintf("%.6f", p_thresh),
        " | level_used=", sprintf("%.6f", unique(boundary_points$level_used)[1])
      )
    ) +
    theme_classic()

  plot_file <- file.path(out_dir, paste0("LC_boundary_posterior_kmin_", k_min, ".png"))
  ggsave(plot_file, p_boundary, width = 7, height = 6, dpi = 300)

  results[[as.character(k_min)]] <- list(
    k_min = k_min,
    auc = auc_val,
    p_thresh = p_thresh,
    tpr = roc_res$best_tpr,
    fpr = roc_res$best_fpr,
    J = roc_res$best_J,
    boundary_file = boundary_tsv,
    plot_file = plot_file
  )
}

# Save summary table
summary_df <- bind_rows(lapply(results, as.data.frame))
summary_file <- file.path(out_dir, "boundary_summary_by_kmin.tsv")
write_tsv(summary_df, summary_file)

message("Done. Outputs written to: ", out_dir)
message("Summary: ", summary_file)
  