setwd("/home/anirjit/ANIRJIT/RESULTS/Diversity/human")

# List all files ending with "_sns"
file_list <- list.files(pattern = "*_sns")

# Read all files into a list of data frames
data_list <- lapply(file_list, read.table, header = TRUE, sep = "\t")

# Extract dataset names dynamically (removing "_sns" suffix)
dataset_names <- gsub("_sns", "", file_list)
dataset_labels <- c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "LCRFinder", "SEG", "SEG\nstrict", "SEG\nIntermediate", "fLPS", "fLPS\nstrict", "fLPS 2.0", "fLPS 2.0\nstrict", "T-REKS", "Xstream")

# Define colors
boxplot_colors <- c("cyan", "lightblue", "violet", "pink", "red", "brown", "green", "lightgreen", "maroon", "seagreen", "yellow", "peru", "grey")

# Open JPEG file
#jpeg("human_diversity.jpg", width = 4000, height = 2000, res = 200)
par(mfrow = c(1,2))

# Boxplot for Shannon Entropy
boxplot(lapply(data_list, function(df) df$Shannon_Entropy),
        names = dataset_labels, col = boxplot_colors,
        main = expression(bold("Shannon Entropies for") ~ bolditalic("Homo sapiens")),
        ylab = "Shannon Entropy", outline = FALSE, cex.axis = 0.7)

# Boxplot for Simpson Diversity
boxplot(lapply(data_list, function(df) df$Simpson_Diversity),
        names = dataset_labels, col = boxplot_colors,
        main = expression(bold("Simpson Diversity Indices for") ~ bolditalic("Homo sapiens")),
        ylab = "Simpson's Diversity", outline = FALSE, cex.axis = 0.7)

#dev.off()
