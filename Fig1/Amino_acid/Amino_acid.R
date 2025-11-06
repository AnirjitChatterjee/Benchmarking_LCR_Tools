setwd("/home/anirjit/ANIRJIT/RESULTS/Amino_acid/human")
library(ggplot2)
library(dplyr)
library(tidyr)

# List all files ending with "_data.txt" (Modify this pattern as needed)
file_list <- list.files(pattern = "*_aa_count")

# Read all files and add a column for dataset name
data_list <- lapply(file_list, function(file) {
  df <- read.table(file, header = TRUE, sep = "\t")
  df$Dataset <- gsub("_aa_count", "", file)  # Extract dataset name
  return(df)
})

# Combine all datasets into one dataframe
merged_data <- bind_rows(data_list)

# Ensure 'Character' is a factor (ordered for better visualization)
merged_data$Character <- factor(merged_data$Character, levels = unique(merged_data$Character))

jpeg("human_aa.jpg", width = 6000, height = 4500, res = 500)
# Plot stacked bar chart
ggplot(merged_data, aes(x = Dataset, y = Proportion, fill = Character)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Relative Amino Acid Proportions in LCRs of" ~bolditalic("Homo sapiens"),
       x = "Tools",
       y = "Proportion") +
  theme(
  plot.title = element_text(hjust = 0.5, size = 16),
  axis.text.x = element_text(angle = 45, vjust = 1, size =12, color = "black"),
  axis.text.y = element_text(angle = 0, vjust = 1, size = 9, color = "black"),
  axis.title.x = element_text(size = 12, face = "bold"),
  axis.title.y = element_text(size = 12, face = "bold"),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank()
  ) +  
  scale_x_discrete(labels = c("AlcoR\n(Mode 1)","AlcoR\n(Mode 2)","Dotplot","fLPS","fLPS\nstrict","fLPS 2.0","fLPS 2.0\nstrict","LCRFinder",
                              "SEG","SEG\nIntermediate","SEG\nstrict","T-REKS","Xstream")) +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999", "#66C2A5",
                               "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F",  "#E5C494", "#B3B3B3", "#1F78B4", "#33A02C", "#CAB2D6",
                               "#85929E", "#EB984E" ))
dev.off()
