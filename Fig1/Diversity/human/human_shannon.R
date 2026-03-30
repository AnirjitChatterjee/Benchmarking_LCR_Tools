setwd("/home/anirjit/ANIRJIT/RESULTS/Diversity/human")

# List all files ending with "_sns"
file_list <- list.files(pattern = "*_SNS")

# Read all files into a list of data frames
data_list <- lapply(file_list, read.table, header = TRUE, sep = "\t")

# Extract dataset names dynamically (removing "_sns" suffix)
dataset_names <- gsub("_SNS", "", file_list)
dataset_labels <- c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS\nstrict", "fLPS 2.0", "fLPS 2.0\nstrict", "LCRFinder", "SEG\nIntermediate", "SEG", "SEG\nstrict", "T-REKS", "Xstream")

# Define colors
boxplot_colors <- c("cyan", "lightblue", "violet", "pink", "red", "brown", "green", "lightgreen", "maroon", "seagreen", "yellow", "peru", "grey")

# Open JPEG file
jpeg("human_shannon.jpg", width = 6000, height = 4500, res = 1000)

# Boxplot for Shannon Entropy
boxplot(lapply(data_list, function(df) df$Shannon_Entropy),
        names = dataset_labels, col = boxplot_colors,
        main = expression(bold("Shannon Entropies for") ~ bolditalic("Homo sapiens")),
        ylab = "Shannon Entropy", outline = FALSE, cex.axis = 0.7,
        axes = FALSE)  # Remove axes

axis(2)  # Adds the y-axis
axis(1, at = 1:length(dataset_labels), labels = dataset_labels, las = 2, cex.axis = 0.8)

dev.off()
