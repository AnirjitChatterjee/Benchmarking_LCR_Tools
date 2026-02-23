This is the README file of "A Benchmarking Framework for Comparative Evaluation of Low-Complexity Region Detection Tools in the Human Proteome".

Folder structure:

Fig1: Contains the relevant LCR metrics folders, Figure 1 and the R code used to generate the figure.
Fig2: Contains the folders “multiinter” and “Python Scripts”, Figure 2 and the R code (Fig2.R) used to generate the figure. 
Fig3: Contains the folder “Purity”, the tsv file “entity_counts” (having the counts of the number of LCRs of various purities, predicted by the different methods), Figure 3 and the R code (Fig3.R) used to generate the figure. 
Fig4: Contains the sorted bed files of LCRs predicted by various tools (files ending with “_sorted.bed”), the bash script “jaccard” to calculate the Jaccard indices, the tsv file “human_jaccard” having the Jaccard indices in a tabular format, Figure 4 and the R code (Fig4.R) used to generate the figure.
Fig5: Contains the files with information on the entropy, most frequent amino acid percentage, and the mutation percentage of LCRs predicted by various tools (files ending with “_plot”), Figure 5, and the R code (Fig5.R) used to generate the figure.
Fig6: Contains the folder “ROC”, Figure 6 and the R code (Fig6.R) used to generate the figure.
Fig7: Contains the folder “ROC”, Figure 7 and the R code (Fig7.R) used to generate the figure.
Fig8: Contains the folders “Disprot” and “PDB” and Figure 8. It also contains the R codes “Disprot.R” and “PDB_missing.R”, used to generate the figure. 
Supplementary material: Contains the supplementary figures and materials. 

Prerequisites:
Bedtools v2.30.0
Python 3.10.12
R (version 4.3.3)
R Packages: readr, dplyr, stringr, purrr, ggplot2, tidyr, tibble, mgcv, Polychrome, cowplot, patchwork, corrplot, tidyverse, viridis
