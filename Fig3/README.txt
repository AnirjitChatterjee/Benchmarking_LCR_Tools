Fig3: Contains the folder “Purity”, the tsv file “entity_counts” (having the counts of the number of LCRs of various purities, predicted by the different methods), Figure 3 and the R code (Fig3.R) used to generate the figure. 

The folder “Purity” contains LCR sequences detected (files ending with “_gf”) and information about the most repeated amino acid in the LCR and its purity (files ending with “_sorted.bed”). The Python script “purity” calculates the most frequent amino acid in the LCR and its purity, and “counter” counts the number of LCRs in each purity category.

Prerequisites:
R (version 4.3.3)
R Packages: ggplot2, tidyr, dplyr, Polychrome
