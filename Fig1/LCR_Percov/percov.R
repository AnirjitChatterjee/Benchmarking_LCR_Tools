# Load required libraries
library(ggplot2)
library(reshape2)

# Set working directory (modify as needed)
setwd("/home/anirjit/ANIRJIT/RESULTS/LCR_Percov/takru")

# Get list of categorized files
files <- list.files(pattern = "_categorized.tsv$")

# Initialize an empty dataframe to store combined data
all_data <- data.frame()

# Loop through files and read data
for (file in files) {
  df <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  
  # Extract file name without extension
  tool_name <- gsub("_categorized.tsv", "", file)
  
  # Add tool name as a column
  df$Tool <- tool_name
  
  # Append data
  all_data <- rbind(all_data, df)
}

# Convert Tool column to a factor (to maintain order)
all_data$Tool <- factor(all_data$Tool, levels = unique(all_data$Tool))

jpeg("takru_lcr_percov.jpg", width = 6000, height = 4500, res = 1000)
# Create heatmap using ggplot2
ggplot(all_data, aes(x = Category, y = Tool, fill = Count)) +
  geom_tile() +  # Heatmap tiles
  scale_fill_gradient(low = "lightyellow2", high = "blue2") +  # Color scale
  labs(title = expression(bold("LCR Percentage Coverage for")~bolditalic("Takifugu rubiripes")),
       x = "LCR Coverage Percentage",
       y = "Tool",
       fill = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 16),
        axis.text.x = element_text(angle = 0, hjust = 1, size = 9, colour = "black"),  # Rotate x-axis labels
        axis.text.y = element_text(size = 8, colour = "black"),
        axis.title.x = element_text(size = 12, face = "bold"),
        panel.grid.major = element_blank(),  # Remove grid
        panel.grid.minor = element_blank()) +
  scale_y_discrete(labels = c("AlcoR\n(Mode 1)", "AlcoR\n(Mode 2)", "Dotplot", "fLPS", "fLPS\nstrict", "fLPS 2.0", "fLPS 2.0\nstrict", "LCRFinder",
                              "SEG", "SEG\nIntermediate", "SEG\nstrict", "T-REKS", "Xstream"))
dev.off()
