Fig7: Contains the folder “ROC”, Figure 7 and the R code (Fig7.R) used to generate the figure.
The folder “ROC” contains a bash script “conf_mat”, which is used to calculate the number of true and false positives, and true and false negatives across the metrics. The folder “ROC” contains four relevant metric folders: “entropy” (entropy ratios of LCR and the protein sequence), “gene_length” (length of the protein), “lcr_cov” (percentage coverage of the protein by the LCR) and “lcr_num” (number of LCRs in the proteins).
 
Prerequisites:
R (version 4.3.3)
R Packages: ggplot2, tidyr, dplyr, patchwork
