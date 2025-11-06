library(ggplot2)
library(tidyr)
library(dplyr)

# Set working directory
setwd("/home/anirjit/ANIRJIT/RESULTS/Purity/human") 

# Get all files ending with "_0.7_bincounts.txt"
files <- list.files(pattern = "_0.7_bincounts.txt$")

# Initialize empty data frame
all_data <- data.frame()

# Read all files and calculate proportions
for (file in files) {
  df <- read.delim(file, sep="\t", header=TRUE)
  
  # Ensure column names are correct
  if (!all(c("Bin", "Count") %in% colnames(df))) {
    cat("Skipping file:", file, " - Missing required columns\n")
    next
  }
  
  # Normalize counts to proportions
  df <- df %>%
    mutate(Proportion = Count / sum(Count)) %>%
    mutate(File = sub("_0.7_bincounts.tsv$", "", file)) # Add file name
  
  # Append to all_data
  all_data <- bind_rows(all_data, df)
}

# Check if data exists
if (nrow(all_data) == 0) {
  stop("No valid data found. Check file contents.")
}

tools <- c("AlcoR 1","AlcoR 2","Dotplot","fLPS","fLPS strict","fLPS 2.0","fLPS 2.0 strict","LCRFinder","SEG","SEG intermediate","SEG strict","T-REKS","Xstream")

# Convert Bin to factor with correct order
all_data$Bin <- factor(all_data$Bin, levels = unique(all_data$Bin))

# Convert to wide format for heatmap
heatmap_data <- all_data %>%
  select(File, Bin, Proportion) %>%
  pivot_wider(names_from = Bin, values_from = Proportion, values_fill = list(Proportion = 0)) 

# Convert back to long format for plotting
heatmap_melt <- pivot_longer(heatmap_data, cols = -File, names_to = "Bin", values_to = "Proportion")

jpeg(filename = "Heatmap_70_Purity.jpg", width = 1500, height = 1000, res = 250, quality = 50)

# Heatmap plot
ggplot(heatmap_melt, aes(x=Bin, y=File, fill=Proportion)) +
  geom_tile(color="white") +
  scale_fill_gradient(low="white", high="red", name="Proportion") +
  scale_y_discrete(labels = tools) +  
  scale_x_discrete() +  # Keep discrete x-axis
  theme_minimal() +  
  theme(
    axis.text.x = element_text(size = 7, hjust = 1, angle = 45),  # Adjust font size & rotate
    axis.text.y = element_text(size = 10),  # Adjust y-axis label size
    plot.title = element_text(hjust=0.5, size=18, face="bold")
  ) +
  labs(x="Protein length", y="Tools", title="Distribution of LCR Positions at 70% purity")
dev.off()
