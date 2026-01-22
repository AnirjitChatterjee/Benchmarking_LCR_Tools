setwd("/home/anirjit/ANIRJIT/RESULTS/Jaccard")

library(corrplot)

jm <- read.delim("human_jaccard.tsv", header = T, sep = "\t", quote = "", row.names = 1)
jm <- as.matrix(jm)


setwd("/home/anirjit/ANIRJIT/images")

jpeg("Fig 4.jpg", width = 6000, height = 4000, res = 500, quality = 100)
corrplot(jm, type = "lower", order = "hclust", method = "color", col = colorRampPalette(c("blue","white","red"))(150), tl.col = "black", tl.cex = 1, cl.cex = 1, number.cex = 1, addCoef.col = "black", col.lim = c(0, 1))
dev.off()

