setwd("/home/anirjit/ANIRJIT/RESULTS/Jaccard")

library(corrplot)
jm <- read.delim("human_jaccard.tsv", header = T, sep = "\t", quote = "", row.names = 1)
jm <- as.matrix(jm)

jpeg("human_jaccard.jpg", width = 6000, height = 4500, res = 500)
corrplot(jm, method = "color", col = colorRampPalette(c("blue","white","red"))(150), tl.col = "black", tl.cex = 1, cl.cex = 1, addCoef.col = "black")
dev.off()

corrplot(jm, type = "upper", order = "hclust", method = "color", col = colorRampPalette(c("blue","white","red"))(150), tl.col = "black", tl.cex = 0.9, cl.cex = 0.9, addCoef.col = "black", col.lim = c(0, 1))
