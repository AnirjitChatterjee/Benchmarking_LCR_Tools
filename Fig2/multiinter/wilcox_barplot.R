library(ggpubr)
library(dplyr)
library(readr)

# Step 1: Get all files ending with "_sns_aa"
files <- list.files(pattern = "_sns_aa$")

# Step 2: Loop through each file
for (file in files) {
  
  # Step 3: Read the Data
  data <- read_delim(file, delim = "\t", col_names = TRUE)
  
  # Step 4: Perform Pairwise Wilcoxon Test
  stat_test <- compare_means(Shannon_Entropy ~ Most_Repeated_Char, data = data, 
                             method = "wilcox.test", p.adjust.method = "bonferroni")
  
  # Step 5: Filter only significant p-values (p < 2e-16)
  significant_tests <- stat_test %>% filter(p.adj < 2e-16)
  
  # Step 6: Compute Means and Sample Sizes
  group_stats <- data %>%
    group_by(Most_Repeated_Char) %>%
    summarise(mean_value = mean(Shannon_Entropy, na.rm = TRUE),
              sample_size = n()) %>%
    ungroup()
  
  # Step 7: Adjust y-positions dynamically for better spacing
  if (nrow(significant_tests) > 0) {
    num_tests <- nrow(significant_tests)
    base_y <- max(data$Shannon_Entropy, na.rm = TRUE) + 0.1  # Start y-position slightly above max
    spacing <- 0.25  # Space between p-values
    significant_tests <- significant_tests %>%
      mutate(y.position = base_y + (seq(0, (num_tests - 1)) * spacing))
  }
  
  # Step 8: Create Clean Boxplot (No Jitter Points) with Title
  plot <- ggboxplot(data, x = "Most_Repeated_Char", y = "Shannon_Entropy") +
    geom_boxplot(fill="skyblue", color="black", outlier.color="red", outlier.shape=16) +
    theme_minimal() +
    labs(title = paste("Shannon Entropies by Most Repeated Amino Acid -", file),
         x = "Most Repeated Amino Acid",
         y = "Shannon Entropy of LCRs") +
    theme(plot.title = element_text(hjust = 0.5)) +  # Center align title
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) 
  
  # Step 9: Add Mean and Sample Size Below Each Box
  plot <- plot + 
    stat_summary(fun = mean, geom = "point", color = "black", shape = 5, size = 1.5) +  # Red dot for mean
    geom_text(data = group_stats, aes(x = Most_Repeated_Char, y = min(data$Shannon_Entropy, na.rm = TRUE) - 0.1, 
                                      label = paste0("Mean: ", round(mean_value, 2), "\nn = ", sample_size)),
              size = 1.5, hjust = 0.5, color = "black")  # Add mean and n below each box
  
  # Step 10: Add Only Significant P-values with Smaller Font Size
  if (nrow(significant_tests) > 0) {
    plot <- plot + stat_pvalue_manual(significant_tests, label = "p.adj", 
                                      bracket.nudge.y = 0.05, 
                                      step.increase = 0.01,
                                      size = 2.5)  # Reduce font size
  }
  
  # Step 11: Save the plot as a PNG file
  ggsave(filename = paste0(file, "_boxplot.jpg"), plot = plot, width = 8, height = 6, dpi = 300)
  
  # Step 12: Print confirmation message
  print(paste("Processed:", file))
}

print("All files processed successfully!")
