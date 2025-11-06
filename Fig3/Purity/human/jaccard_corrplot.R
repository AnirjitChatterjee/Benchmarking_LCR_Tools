setwd("/home/anirjit/ANIRJIT/RESULTS/Purity/human")

library(corrplot)
jm <- read.delim("jaccard_matrix.tsv", header = T, sep = "\t", quote = "", row.names = 1)
jm <- as.matrix(jm)

jpeg("human_purity_jaccard.jpg", width = 10000, height = 8000, res = 1000)
corrplot(jm, method = "color", col = colorRampPalette(c("blue","white","red"))(150), tl.col = "black", tl.cex = 0.1, cl.cex = 0.1)
dev.off()
