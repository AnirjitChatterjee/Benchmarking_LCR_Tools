library(corrplot)

# Method names
methods <- c("AlcoR (Mode 2)", "AlcoR (Mode 1)", "Dotplot", "fLPS 2.0", "fLPS 2.0 strict",
             "fLPS", "fLPS strict", "LCRFinder", "SEG", "SEG intermediate",
             "SEG strict", "T-REKS", "Xstream")

# Create empty matrix
mat <- matrix(NA, nrow = 13, ncol = 13)
colnames(mat) <- rownames(mat) <- methods

# Values list (corrected)
values <- list(
  c(),  
  c(72.36),  
  c(3.69, 3.76),  
  c(8.52, 10.32, 4.8),
  c(7.96, 9.49, 6.3, 67.28),
  c(8.55, 10.34, 4.84, 94.62, 67.58),
  c(7.93, 9.42, 6.71, 62.33, 85.84, 63.04),
  c(2.99, 2.99, 25.85, 2.66, 3.75, 2.69, 4),
  c(5.1, 5.32, 37.6, 9.81, 12.35, 9.9, 13.06, 18.53),
  c(3.13, 3.17, 31.58, 2.2, 3.18, 2.22, 3.42, 24.46, 21.36),
  c(1.72, 1.73, 11.25, 0.56, 0.82, 0.57, 0.89, 14.53, 5.59, 25.3),
  c(11.93, 11.81, 12.91, 4.2, 5.89, 4.24, 6.3, 10.71, 13.99, 16.62, 7.5),
  c(8.24, 7.83, 1.37, 1.25, 1.84, 1.26, 1.98, 1.95, 1.86, 2.14, 0.55, 14.69)
)

# Fill lower triangle
for (i in 2:13) {
  mat[i, 1:(i-1)] <- values[[i]]
}

# Mirror lower to upper triangle
mat[upper.tri(mat)] <- t(mat)[upper.tri(mat)]

# Set diagonal (optional)
diag(mat) <- 100



setwd("/home/anirjit/ANIRJIT/RESULTS/Jaccard")

library(corrplot)
jm <- read.delim("human_jaccard.tsv", header = T, sep = "\t", quote = "", row.names = 1)
jm <- as.matrix(jm)



setwd("/home/anirjit/ANIRJIT/ROC2/human/images")

jpeg("Fig 4.jpg", width = 6000, height = 4000, res = 500, quality = 100)
par(mfrow = c(1, 2))
corrplot(type = "lower", order = "hclust", mat, method = "color", is.corr = FALSE,
         col = colorRampPalette(c("white", "blue"))(200), tl.col = "black",
         tl.cex = 0.9, number.cex = 0.7, addCoef.col = "black", col.lim = c(0, 100))
mtext("A", side = 3, line = 0.5, adj = 0.1, font = 2, cex = 1.5)
corrplot(jm, type = "upper", order = "hclust", method = "color", col = colorRampPalette(c("blue","white","red"))(150), tl.col = "black", tl.cex = 0.9, cl.cex = 0.9, number.cex = 0.7, addCoef.col = "black", col.lim = c(0, 1))
mtext("B", side = 3, line = 0.5, adj = 0, font = 2, cex = 1.5)
dev.off()