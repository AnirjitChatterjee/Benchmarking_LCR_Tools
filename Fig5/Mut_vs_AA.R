setwd("/home/anirjit/ANIRJIT/RESULTS/human_com_plot")
library(ggplot2)
library(dplyr)
library(tidyr)

# Get all files ending with "_plot"
files <- list.files(pattern = "_plot$")

for (file in files) {
  # Read input data
  A <- read.table(file = file, header = TRUE)
  
  # Bin both variables to 0–9
  A$MutBin <- round(A$Mutation_Percent / 10, 0)
  A$FreqBin <- round(A$Most_Frequent_AA_Percent / 10, 0)
  
  # Create count table
  F <- as.data.frame(table(A$MutBin, A$FreqBin))
  colnames(F) <- c("MutBin", "FreqBin", "Freq")
  
  # Convert to factors with full levels 0–9
  F$MutBin <- factor(F$MutBin, levels = 0:9)
  F$FreqBin <- factor(F$FreqBin, levels = 0:9)
  
  # Generate complete grid of combinations
  complete_grid <- expand.grid(MutBin = factor(0:9), FreqBin = factor(0:9))
  
  # Join with F to fill in missing bins with Freq = 0
  F_complete <- left_join(complete_grid, F, by = c("MutBin", "FreqBin"))
  F_complete$Freq[is.na(F_complete$Freq)] <- 0
  
  # Plot
  p <- ggplot(F_complete, aes(x = MutBin, y = FreqBin, fill = Freq)) +
    geom_tile() +
    scale_fill_gradient(
      low = "white", high = "red", trans = "log1p",  # log1p avoids log(0)
      breaks = c(0, 1, 10, 100, 1000, max(F_complete$Freq))
    ) +
    labs(
      title = paste("Heatmap of Sequence Counts for", file),
      x = "Mutation Percent (binned)",
      y = "Most Frequent AA Percent (binned)",
      fill = "Count"
    ) +
    theme_gray() +
    theme(
      axis.text.x = element_text(size = 5, angle = 45, hjust = 1),
      axis.text.y = element_text(size = 5),
      axis.title.x = element_text(size = 10),
      axis.title.y = element_text(size = 10)
    )
  
  # Save the plot
  output_file <- paste0(file, "_Mut_vs_AA.jpg")
  jpeg(filename = output_file, width = 1800, height = 1200, res = 500, quality = 100)
  print(p)
  dev.off()
}
