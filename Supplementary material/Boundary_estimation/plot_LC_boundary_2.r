# Fast GAM-based LC boundary estimation
# Key speedups:
# - downsample train set (especially negatives)
# - use mgcv::bam(..., discrete=TRUE, nthreads=...)
# - coarser prediction grid for contouring
#
# install.packages(c("readr","dplyr","stringr","purrr","tidyr","tibble","ggplot2","mgcv"))
setwd("/home/anirjit/ANIRJIT/images_R1/multi_complexity/multi_complexity")

library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)
library(tibble)
library(ggplot2)
library(mgcv)

set.seed(1)

# ----------------------------
# Paths
# ----------------------------
lcr_dir <- "contour_plots"
bg_file <- file.path("uniprot", "PDB_missing_complexity")

stopifnot(dir.exists(lcr_dir))
stopifnot(file.exists(bg_file))

out_dir <- "boundary_outputs_gam_fast"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ----------------------------
# Parameters
# ----------------------------
test_frac <- 0.25
k_min_list <- c(13, 12, 11, 10, 9, 8, 7)

# Training downsampling caps (main speed lever)
max_pos_train <- 50000
max_neg_train <- 50000

# Testing caps (for ROC speed and consistency)
max_pos_test <- 50000
max_neg_test <- 50000

# Grid for plotting and contour extraction
grid_step <- 2  # increase to 3 or 4 for more speed
x_grid <- seq(0, 100, by = grid_step)
y_grid <- seq(0, 100, by = grid_step)

# GAM controls
gam_k <- 25  # lower = faster and smoother; 20-35 is a good range
nthreads <- max(1L, parallel::detectCores(logical = TRUE) - 1L)

# Threshold contour nudge
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

cap_sample <- function(df, n_max) {
  if (is.infinite(n_max) || nrow(df) <= n_max) return(df)
  df %>% slice_sample(n = n_max)
}

# Fast ROC + Youden J
# Sort scores descending once, compute cumulative TPR/FPR efficiently.
roc_youden_fast <- function(scores, labels) {
  ok <- is.finite(scores) & (labels %in% c(0, 1))
  scores <- scores[ok]
  labels <- labels[ok]

  P <- sum(labels == 1)
  N <- sum(labels == 0)
  if (P == 0 || N == 0) stop("Need both classes for ROC.")

  ord <- order(scores, decreasing = TRUE)
  s <- scores[ord]
  y <- labels[ord]

  tp <- cumsum(y == 1)
  fp <- cumsum(y == 0)

  tpr <- tp / P
  fpr <- fp / N

  # thresholds are the score values, but multiple rows can share the same score
  # keep only last occurrence of each unique score (so ROC steps are correct)
  last_idx <- which(!duplicated(s, fromLast = TRUE))

  tpr_u <- tpr[last_idx]
  fpr_u <- fpr[last_idx]
  thr_u <- s[last_idx]

  J <- tpr_u - fpr_u
  best_idx <- which(J == max(J, na.rm = TRUE))
  best_idx <- best_idx[length(best_idx)]

  # AUC via trapezoid on the unique-step ROC
  o2 <- order(fpr_u, tpr_u)
  auc <- sum(diff(fpr_u[o2]) * (tpr_u[o2][-1] + tpr_u[o2][-length(tpr_u[o2])]) / 2)

  list(
    best_threshold = thr_u[best_idx],
    best_tpr = tpr_u[best_idx],
    best_fpr = fpr_u[best_idx],
    best_J = J[best_idx],
    auc = auc
  )
}

extract_boundary_from_ggplot <- function(grid_df, level, eps = 1e-6) {
  gdat <- grid_df %>%
    transmute(x = x, y = y, z = z) %>%
    filter(is.finite(z))

  levels_try <- unique(c(level, level + eps, level - eps))
  levels_try <- levels_try[is.finite(levels_try)]

  for (lv in levels_try) {
    p <- ggplot(gdat, aes(x = x, y = y, z = z)) +
      stat_contour(breaks = lv)

    built <- ggplot_build(p)
    if (length(built$data) < 1) next
    d <- built$data[[1]]
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

  # Downsample for speed
  pos_train <- cap_sample(pos_train, max_pos_train)
  neg_train <- cap_sample(neg_train, max_neg_train)
  pos_test  <- cap_sample(pos_test,  max_pos_test)
  neg_test  <- cap_sample(neg_test,  max_neg_test)

  train_df <- bind_rows(
    pos_train %>% transmute(x = Mutation_Percent, y = Most_Frequent_AA_Percent, label = 1L),
    neg_train %>% transmute(x = Mutation_Percent, y = Most_Frequent_AA_Percent, label = 0L)
  ) %>% filter(is.finite(x), is.finite(y))

  test_df <- bind_rows(
    pos_test %>% transmute(x = Mutation_Percent, y = Most_Frequent_AA_Percent, label = 1L),
    neg_test %>% transmute(x = Mutation_Percent, y = Most_Frequent_AA_Percent, label = 0L)
  ) %>% filter(is.finite(x), is.finite(y))

  # Fit fast GAM with bam
  bam_fit <- mgcv::bam(
    label ~ te(x, y, bs = "tp", k = gam_k),
    data = train_df,
    family = binomial(link = "logit"),
    method = "fREML",
    discrete = TRUE,
    nthreads = nthreads
  )

  # Predict on held-out test
  test_scores <- as.numeric(predict(bam_fit, newdata = test_df, type = "response"))

  roc_res <- roc_youden_fast(test_scores, test_df$label)
  p_thresh <- roc_res$best_threshold
  auc_val <- roc_res$auc

  message(
    "AUC=", sprintf("%.3f", auc_val),
    " | p_thresh=", sprintf("%.6f", p_thresh),
    " | TPR=", sprintf("%.3f", roc_res$best_tpr),
    " | FPR=", sprintf("%.3f", roc_res$best_fpr),
    " | train_pos=", nrow(pos_train),
    " | train_neg=", nrow(neg_train),
    " | grid_step=", grid_step,
    " | threads=", nthreads
  )

  # Predict on grid for contouring
  grid_df <- expand_grid(x = x_grid, y = y_grid)
  grid_df$z <- as.numeric(predict(bam_fit, newdata = grid_df, type = "response"))

  # Extract boundary
  boundary_points <- extract_boundary_from_ggplot(grid_df, p_thresh, eps = contour_eps)

  message(
    "Boundary extraction=bam + ggplot_stat_contour",
    " | n_points=", nrow(boundary_points),
    " | n_pieces=", if (nrow(boundary_points) > 0) dplyr::n_distinct(boundary_points$piece_id) else 0
  )

  if (nrow(boundary_points) == 0) {
    message("No usable boundary pieces found for k_min=", k_min, " at p_thresh=", sprintf("%.6f", p_thresh))
    next
  }

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
  boundary_tsv <- file.path(out_dir, paste0("LC_boundary_points_BAM_kmin_", k_min, ".tsv"))
  write_tsv(boundary_points, boundary_tsv)

  # Save grid surface (optional but useful)
  grid_tsv <- file.path(out_dir, paste0("LC_posterior_surface_BAM_kmin_", k_min, ".tsv"))
  write_tsv(grid_df, grid_tsv)

  # Plot
  p_boundary <- ggplot(grid_df, aes(x = x, y = y)) +
    geom_raster(aes(fill = z), interpolate = FALSE) +
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
    scale_fill_viridis_c(option = "C", name = "P(LCR | BAM)") +
    labs(
      x = "Mutation (%)",
      y = "Most frequent amino acid (%)",
      title = "BAM (fast GAM) posterior map with ROC-optimized boundary",
      subtitle = paste0(
        "k_min=", k_min,
        " | GAM te(x,y) k=", gam_k,
        " | held-out AUC=", sprintf("%.3f", auc_val),
        " | p_thresh=", sprintf("%.6f", p_thresh),
        " | grid_step=", grid_step,
        " | train pos/neg=", nrow(pos_train), "/", nrow(neg_train)
      )
    ) +
    theme_classic()

  plot_file <- file.path(out_dir, paste0("LC_boundary_BAM_kmin_", k_min, ".png"))
  ggsave(plot_file, p_boundary, width = 7, height = 6, dpi = 300)

  results[[as.character(k_min)]] <- list(
    k_min = k_min,
    auc = auc_val,
    p_thresh = p_thresh,
    tpr = roc_res$best_tpr,
    fpr = roc_res$best_fpr,
    J = roc_res$best_J,
    boundary_file = boundary_tsv,
    surface_file = grid_tsv,
    plot_file = plot_file,
    gam_k = gam_k,
    grid_step = grid_step,
    train_pos = nrow(pos_train),
    train_neg = nrow(neg_train)
  )
}

summary_df <- bind_rows(lapply(results, as.data.frame))
summary_file <- file.path(out_dir, "boundary_summary_by_kmin_BAM.tsv")
write_tsv(summary_df, summary_file)

message("Done. Outputs written to: ", out_dir)
message("Summary: ", summary_file)
