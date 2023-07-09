## ------------------------ Script Information ---------------------------------
##
## Script name: extended_data_figs.R
##
## Purpose of script: This script generates Extended Data 
##    Fig 1 and 2 in Coughlin et al. (2023). 
##
## Author: Justin G. Coughlin, M.S.
##
## Date Created: 2022-03-01
## Modified: 2023-7-06
##
## Email: justin.coughlin@outlook.com
##
##
## Notes: These data were collected using funding from the U.S. 
## Government and can be used without additional permissions or fees. 
##
## Note: tree_level_effects_2020_2019.csv is needed for this script.
##
## Minimum RAM Needed: 8 GB
##
## ------------------------- Script Begin --------------------------------------
# Clear global environment
rm(list = ls(all.names = TRUE))

## ------------------ Load libraries and make directories ----------------------
library(easypackages)
libraries("ggplot2", "dplyr", "tidyr", "dplyr", "openxlsx", "tictoc", 
          "tidyverse", "ggpubr", "purrr", "ggridges", "viridis", "hrbrthemes")

# Timekeeping
tic("Environment setting")

# Directory list
base_dir <- "C:/Users/justi/OneDrive/Documents" # Typically take base_dir to Docs/
file_dir <- file.path(base_dir, "Projects/20-Year Tree Effects/Data_Submission/process_files")
# Timekeeping
toc()
tic("Data loading and processing")


## --------------------------- Load data ---------------------------------------
# Pull in the RTI database with the joined TDep values (2000-2019)
setwd(file_dir)
tree_effects <- read.csv("tree_level_effects_2000_2019.csv")
# Timekeeping
toc()
tic("Generate the phenotype box plot figure")


#------------------------ Phenotype box plots ----------------------------------

# Subset the data that is needed
sub <- subset(tree_effects, select = c("Gen_Spp", "G_N_00", "G_N_19", "S_N_00", 
                                     "S_N_19", "G_S_00", "G_S_19", "S_S_00",
                                     "S_S_19", "pheno.type", "Wood.Products"))
# Make the neither category
sub <- sub %>%
  mutate(Wood.Products = case_when(is.na(Wood.Products) ~ "Neither",
                                     TRUE ~ Wood.Products))
# Replace "D" with "Deciduous" and "E" with "Evergreen"
sub$pheno.type <- ifelse(sub$pheno.type == "D", "Deciduous",
                         ifelse(sub$pheno.type == "E", "Evergreen", sub$pheno.type))
# Multiply columns by 100
sub[, grep("^G_N_00$|^G_N_19$|^S_N_00$|^S_N_19$|^G_S_00$|^G_S_19$|^S_S_00$|^S_S_19$", colnames(sub))] <- 
  sub[, grep("^G_N_00$|^G_N_19$|^S_N_00$|^S_N_19$|^G_S_00$|^G_S_19$|^S_S_00$|^S_S_19$", colnames(sub))] * 100

# Make the difference columns
sub$GN_change <- with(sub, G_N_19-G_N_00)
sub$SN_change <- with(sub, S_N_19-S_N_00)
sub$GS_change <- with(sub, G_S_19-G_S_00)
sub$SS_change <- with(sub, S_S_19-S_S_00)

# Create boxplot with outliers
a <- ggplot(sub, aes(y = G_N_00, x = pheno.type)) +
  geom_violin() +
  ylim(-50,100) +
  labs(title  = "N-Influenced Growth Rate Effect (2000)", x = "Phenology",
       y = "Growth Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
b <- ggplot(sub, aes(y = G_N_19, x = pheno.type)) +
  geom_violin() +
  ylim(-50,100) +
  labs(title  = "N-Influenced Growth Rate Effect (2019)", x = "Phenology",
       y = "Growth Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20,
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
c <- ggplot(sub, aes(y = GN_change, x = pheno.type)) +
  geom_violin() +
  labs(title  = "N-Influenced Growth Rate Change (2000-2019)", x = "Phenology",
       y = "Growth Rate Effect Change (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
d <- ggplot(sub, aes(y = S_N_00, x = pheno.type)) +
  geom_violin() +
  ylim(-20,10) +
  labs(title  = "N-Influenced Survival Rate Effect (2000)", x = "Phenology",
       y = "Survival Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
e <- ggplot(sub, aes(y = S_N_19, x = pheno.type)) +
  geom_violin() +
  ylim(-20,10) +
  labs(title  = "N-Influenced Survival Rate Effect (2019)", x = "Phenology",
       y = "Survival Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
f <- ggplot(sub, aes(y = SN_change, x = pheno.type)) +
  geom_violin() +
  labs(title  = "N-Influenced Survival Rate Change (2000-2019)", x = "Phenology",
       y = "Survival Rate Effect Change (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
g <- ggplot(sub, aes(y = G_S_00, x = pheno.type)) +
  geom_violin() +
  ylim(-50,0) +
  labs(title  = "S-Influenced Growth Rate Effect (2000)", x = "Phenology",
       y = "Growth Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
h <- ggplot(sub, aes(y = G_S_19, x = pheno.type)) +
  geom_violin() +
  ylim(-50,0) +
  labs(title  = "S-Influenced Growth Rate Effect (2019)", x = "Phenology",
       y = "Growth Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
i <- ggplot(sub, aes(y = GS_change, x = pheno.type)) +
  geom_violin() +
  labs(title  = "S-Influenced Growth Rate Change (2000-2019)", x = "Phenology",
       y = "Growth Rate Effect Change (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
j <- ggplot(sub, aes(y = S_S_00, x = pheno.type)) +
  geom_violin() +
  ylim(-30,0) +
  labs(title  = "S-Influenced Survival Rate Effect (2000)", x = "Phenology",
       y = "Survival Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
k <- ggplot(sub, aes(y = S_S_19, x = pheno.type)) +
  geom_violin() +
  ylim(-30,0) +
  labs(title  = "S-Influenced Survival Rate Effect (2019)", x = "Phenology",
       y = "Survival Rate Effect (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Create boxplot with outliers
l <- ggplot(sub, aes(y = SS_change, x = pheno.type)) +
  geom_violin() +
  labs(title  = "S-Influenced Survival Rate Change (2000-2019)", x = "Phenology",
       y = "Survival Rate Effect Change (%)") +
  theme(text = element_text(size = 20), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 20, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 20, colour = "black"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 20, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA))

# Compile the multi-pael figure
figure <- ggarrange(a,b,c,d,e,f,g,h,i,j,k,l,
                    labels=c("a", "b", "c", "d", "e", "f", "g", "h","i", "j", "k", "l"),
                    ncol = 3, nrow = 4, legend = "bottom",
                    common.legend = TRUE)

# Export the figure
png("Figure_S7.png", height = 2000, width = 1500)
figure
dev.off()

# Export the figure as PDF
ggsave("Fig_S7.pdf", figure, height = 20, width = 15, units = "in", 
       dpi = 600)
# Timekeeping
toc()
tic("Generate the K-S test figure")


#------------------------------ K-S plots --------------------------------------

## Growth Nitrogen
# Calculate the 2.5th and 97.5th percentiles for each column
pct_5 <- apply(sub[, c("G_N_00", "G_N_19")], 2, quantile, probs = 0.05, na.rm = TRUE)
pct_95 <- apply(sub[, c("G_N_00", "G_N_19")], 2, quantile, probs = 0.95, na.rm = TRUE)

# Filter the data to remove values below the 2.5th percentile and above the 97.5th percentile
sub_filtered <- subset(sub, 
                       G_N_00 >= pct_5[1] & G_N_19 >= pct_5[2] &
                         G_N_00 <= pct_95[1] & G_N_19 <= pct_95[2] &
                         !is.na(G_N_00) & !is.na(G_N_19))

# Add random noise to the filtered data to avoid ties
sub_filtered$G_N_00 <- jitter(sub_filtered$G_N_00)
sub_filtered$G_N_19 <- jitter(sub_filtered$G_N_19)

# Split the filtered data by pheno.type
sub_split_filtered <- split(sub_filtered[, c("G_N_00", "G_N_19")], 
                            sub_filtered$pheno.type)

# Perform the K-S test on the filtered data
ks_res_1 <- ks.test(sub_split_filtered[[1]][, 1], sub_split_filtered[[2]][, 1])
ks_res_2 <- ks.test(sub_split_filtered[[1]][, 2], sub_split_filtered[[2]][, 2])

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 1])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 1])

# Calculate the G_N_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
gn00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the G_N_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
gn00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 2])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 2])

# Calculate the G_N_19 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 2], 
                        sub_split_filtered[[2]][, 2])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
gn19_max_ks <- x_vals[which.max(diff_vals)]

# Store the results in a data frame
ks_results <- data.frame(statistic = c(ks_res_1$statistic, ks_res_2$statistic),
                         p.value = c(ks_res_1$p.value, ks_res_2$p.value),
                         method = rep("K-S test", 2))

# Create two separate plots, one for each variable
a <- ggplot(sub_filtered, aes(x = G_N_00, color = pheno.type)) +
  stat_ecdf(linewidth=1.5) +
  labs(x = "Growth Rate Effect (%)", y = "Cumulative Probability", 
       title = "N-Influenced Growth Rate Effect (2000)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = gn00_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = 0, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_1$statistic, 3))) +
  annotate("text", y = 0.75, x = 0, size = 3.5,
           label = paste0("p-value < 0.001")) +
  xlim(-10,120) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "left")

b <- ggplot(sub_filtered, aes(x = G_N_19, color = pheno.type)) +
  stat_ecdf(linewidth = 1.5) +
  labs(x = "Growth Rate Effect (%)", y = "Cumulative Probability", 
       title = "N-Influenced Growth Rate Effect (2019)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = gn19_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = 0, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_2$statistic, 3))) +
  annotate("text", y = 0.75, x = 0, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "right")

## Survival Nitrogen
# Calculate the 2.5th and 97.5th percentiles for each column
pct_5 <- apply(sub[, c("S_N_00", "S_N_19")], 2, quantile, probs = 0.05, 
               na.rm = TRUE)
pct_95 <- apply(sub[, c("S_N_00", "S_N_19")], 2, quantile, probs = 0.95, 
                na.rm = TRUE)

# Filter the data to remove values below the 2.5th percentile and 
# above the 97.5th percentile
sub_filtered <- subset(sub, 
                       S_N_00 >= pct_5[1] & S_N_19 >= pct_5[2] &
                         S_N_00 <= pct_95[1] & S_N_19 <= pct_95[2] &
                         !is.na(S_N_00) & !is.na(S_N_19))

# Add random noise to the filtered data to avoid ties
sub_filtered$S_N_00 <- jitter(sub_filtered$S_N_00)
sub_filtered$S_N_19 <- jitter(sub_filtered$S_N_19)

# Split the filtered data by pheno.type
sub_split_filtered <- split(sub_filtered[, c("S_N_00", "S_N_19")], 
                            sub_filtered$pheno.type)

# Perform the K-S test on the filtered data
ks_res_1 <- ks.test(sub_split_filtered[[1]][, 1], sub_split_filtered[[2]][, 1])
ks_res_2 <- ks.test(sub_split_filtered[[1]][, 2], sub_split_filtered[[2]][, 2])

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 1])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 1])

# Calculate the S_N_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
sn00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the S_N_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
sn00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 2])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 2])

# Calculate the S_N_19 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 2], 
                        sub_split_filtered[[2]][, 2])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
sn19_max_ks <- x_vals[which.max(diff_vals)]

# Store the results in a data frame
ks_results <- data.frame(statistic = c(ks_res_1$statistic, ks_res_2$statistic),
                         p.value = c(ks_res_1$p.value, ks_res_2$p.value),
                         method = rep("K-S test", 2))

# Create two separate plots, one for each variable
c <- ggplot(sub_filtered, aes(x = S_N_00, color = pheno.type)) +
  stat_ecdf(linewidth=1.5) +
  labs(x = "Survival Rate Effect (%)", y = "Cumulative Probability", 
       title = "N-Influenced Survival Rate Effect (2000)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = sn00_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = -5.5, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_1$statistic, 3))) +
  annotate("text", y = 0.75, x = -5.5, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "left")

d <- ggplot(sub_filtered, aes(x = S_N_19, color = pheno.type)) +
  stat_ecdf(linewidth = 1.5) +
  labs(x = "Survival Rate Effect (%)", y = "Cumulative Probability", 
       title = "N-Influenced Survival Rate Effect (2019)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = sn19_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = -2.5, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_2$statistic, 3))) +
  annotate("text", y = 0.75, x = -2.5, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "right")

## Growth Sulfur
# Calculate the 2.5th and 97.5th percentiles for each column
pct_5 <- apply(sub[, c("G_S_00", "G_S_19")], 2, quantile, probs = 0.05, 
               na.rm = TRUE)
pct_95 <- apply(sub[, c("G_S_00", "G_S_19")], 2, quantile, probs = 0.95, 
                na.rm = TRUE)

# Filter the data to remove values below the 2.5th percentile and above the 97.5th percentile
sub_filtered <- subset(sub, 
                       G_S_00 >= pct_5[1] & G_S_19 >= pct_5[2] &
                         G_S_00 <= pct_95[1] & G_S_19 <= pct_95[2] &
                         !is.na(G_S_00) & !is.na(G_S_19))

# Add random noise to the filtered data to avoid ties
sub_filtered$G_S_00 <- jitter(sub_filtered$G_S_00)
sub_filtered$G_S_19 <- jitter(sub_filtered$G_S_19)

# Split the filtered data by pheno.type
sub_split_filtered <- split(sub_filtered[, c("G_S_00", "G_S_19")], 
                            sub_filtered$pheno.type)

# Perform the K-S test on the filtered data
ks_res_1 <- ks.test(sub_split_filtered[[1]][, 1], sub_split_filtered[[2]][, 1])
ks_res_2 <- ks.test(sub_split_filtered[[1]][, 2], sub_split_filtered[[2]][, 2])

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 1])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 1])

# Calculate the G_S_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
gs00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the G_S_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
gs00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 2])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 2])

# Calculate the G_S_19 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 2], 
                        sub_split_filtered[[2]][, 2])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
gs19_max_ks <- x_vals[which.max(diff_vals)]

# Store the results in a data frame
ks_results <- data.frame(statistic = c(ks_res_1$statistic, ks_res_2$statistic),
                         p.value = c(ks_res_1$p.value, ks_res_2$p.value),
                         method = rep("K-S test", 2))

# Create two separate plots, one for each variable
e <- ggplot(sub_filtered, aes(x = G_S_00, color = pheno.type)) +
  stat_ecdf(linewidth=1.5) +
  labs(x = "Growth Rate Effect (%)", y = "Cumulative Probability", 
       title = "S-Influenced Growth Rate Effect (2000)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = gs00_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = -30, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_1$statistic, 3))) +
  annotate("text", y = 0.75, x = -30, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "left")

f <- ggplot(sub_filtered, aes(x = G_S_19, color = pheno.type)) +
  stat_ecdf(linewidth = 1.5) +
  labs(x = "Growth Rate Effect (%)", y = "Cumulative Probability", 
       title = "S-Influenced Growth Rate Effect (2019)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = gs19_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = -16, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_2$statistic, 3))) +
  annotate("text", y = 0.75, x = -16, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "right")

## Survival Sulfur
# Calculate the 2.5th and 97.5th percentiles for each column
pct_5 <- apply(sub[, c("S_S_00", "S_S_19")], 2, quantile, probs = 0.05, 
               na.rm = TRUE)
pct_95 <- apply(sub[, c("S_S_00", "S_S_19")], 2, quantile, probs = 0.95, 
                na.rm = TRUE)

# Filter the data to remove values below the 2.5th percentile and above the 97.5th percentile
sub_filtered <- subset(sub, 
                       S_S_00 >= pct_5[1] & S_S_19 >= pct_5[2] &
                         S_S_00 <= pct_95[1] & S_S_19 <= pct_95[2] &
                         !is.na(S_S_00) & !is.na(S_S_19))

# Add random noise to the filtered data to avoid ties
sub_filtered$S_S_00 <- jitter(sub_filtered$S_S_00)
sub_filtered$S_S_19 <- jitter(sub_filtered$S_S_19)

# Split the filtered data by pheno.type
sub_split_filtered <- split(sub_filtered[, c("S_S_00", "S_S_19")], 
                            sub_filtered$pheno.type)

# Perform the K-S test on the filtered data
ks_res_1 <- ks.test(sub_split_filtered[[1]][, 1], sub_split_filtered[[2]][, 1])
ks_res_2 <- ks.test(sub_split_filtered[[1]][, 2], sub_split_filtered[[2]][, 2])

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 1])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 1])

# Calculate the S_S_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
ss00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the S_S_00 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 1], 
                        sub_split_filtered[[2]][, 1])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
ss00_max_ks <- x_vals[which.max(diff_vals)]

# Calculate the ECDF for each group
ecdf_1 <- ecdf(sub_split_filtered[[1]][, 2])
ecdf_2 <- ecdf(sub_split_filtered[[2]][, 2])

# Calculate the S_S_19 value where the K-S statistic is largest
x_vals <- sort(unique(c(sub_split_filtered[[1]][, 2], 
                        sub_split_filtered[[2]][, 2])))
diff_vals <- abs(ecdf_1(x_vals) - ecdf_2(x_vals))
ss19_max_ks <- x_vals[which.max(diff_vals)]

# Store the results in a data frame
ks_results <- data.frame(statistic = c(ks_res_1$statistic, ks_res_2$statistic),
                         p.value = c(ks_res_1$p.value, ks_res_2$p.value),
                         method = rep("K-S test", 2))

# Create two separate plots, one for each variable
g <- ggplot(sub_filtered, aes(x = S_S_00, color = pheno.type)) +
  stat_ecdf(linewidth=1.5) +
  labs(x = "Survival Rate Effect (%)", y = "Cumulative Probability", 
       title = "S-Influenced Survival Rate Effect (2000)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = ss00_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = -18.5, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_1$statistic, 3))) +
  annotate("text", y = 0.75, x = -18.5, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "left")

h <- ggplot(sub_filtered, aes(x = S_S_19, color = pheno.type)) +
  stat_ecdf(linewidth = 1.5) +
  labs(x = "Survival Rate Effect (%)", y = "Cumulative Probability", 
       title = "S-Influenced Survival Rate Effect (2019)",
       color = "Phenotype") +
  scale_color_manual(values = c("dodgerblue", "olivedrab")) +
  geom_vline(xintercept = ss19_max_ks, linetype = "dashed") +
  annotate("text", y = 0.8, x = -5.75, size = 3.5,
           label = paste0("K-S Statistic = ", round(ks_res_2$statistic, 3))) +
  annotate("text", y = 0.75, x = -5.75, size = 3.5,
           label = paste0("p-value < 0.001")) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_rect(fill = "white")) +
  scale_y_continuous(position = "right")

# Generate the multi-panel figure
figure <- ggarrange(a,b,c,d,e,f,g,h,
                    labels=c("a", "b", "c", "d", "e", "f", "g", "h"),
                    ncol = 2, nrow = 4, legend = "bottom",
                    common.legend = TRUE)

# Export the figure
png("Extended_Data_Fig_1.png", height = 2000, width = 1500)
figure
dev.off()

# Export the figure as PDF
ggsave("Extended_Data_Fig_1.pdf", figure, height = 20, width = 15, units = "in", 
       dpi = 600)
# Timekeeping
toc()


#---------------------- Wood Product Ridgeline ---------------------------------
# Subset the needed columns
sub_2 <- subset(sub, select=c("G_N_00", "G_N_19", "Wood.Products"))
sub_2 <- sub_2 %>%
  rename(`2000`=G_N_00,
         `2019`=G_N_19, 
         `Wood Products` = Wood.Products)
sub_gat <- gather(sub_2, key="Year", value="Effect", `2000`:`2019`)

sub_gat$`Wood Products` <- factor(sub_gat$`Wood Products`, 
                                levels = c("B", "UP", "UP+B", "Neither"))

# Plot the ridgeline 
a <- ggplot(sub_gat, aes(x = Effect, y = `Wood Products`, fill=`Wood Products`)) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01, alpha=0.2) +
  scale_fill_manual(name = "", values = c("UP" = "#F8766D", 
                                          "B" = "#00BFC4", 
                                          "UP+B" = "#619CFF",
                                          "Neither" = "#AAAAAA")) +
  labs(title = 'N-Influenced Growth Rate \nby Wood Products',
       x="Growth Rate Effect (%)") +
  xlim(-50,150) +
  theme_ipsum() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        axis.title.x = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        axis.title.y = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_blank(),
        legend.spacing.x = unit(1.2, "cm"),
        strip.text = element_text(size = 20, face = "bold")) +
  facet_wrap(~Year, scales = "free_x", nrow = 2, ncol = 1)

# Subset the needed columns
sub_2 <- subset(sub, select=c("S_N_00", "S_N_19", "Wood.Products"))
sub_2 <- sub_2 %>%
  rename(`2000`=S_N_00,
         `2019`=S_N_19,
         `Wood Products` = Wood.Products)
sub_gat <- gather(sub_2, key="Year", value="Effect", `2000`:`2019`)

sub_gat$`Wood Products` <- factor(sub_gat$`Wood Products`, 
                                levels = c("B", "UP", "UP+B", "Neither"))

# Plot the ridgeline 
b <- ggplot(sub_gat, aes(x = Effect, y = `Wood Products`, fill=`Wood Products`)) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01, alpha=0.2) +
  scale_fill_manual(name = "", values = c("UP" = "#F8766D", 
                                          "B" = "#00BFC4", 
                                          "UP+B" = "#619CFF", 
                                          "Neither" = "#AAAAAA")) +
  labs(title = 'N-Influenced Survival Rate \nby Wood Products',
       x="Survival Rate Effect (%)") +
  xlim(-20,5) +
  theme_ipsum() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        axis.title.x = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        axis.title.y = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_blank(),
        legend.spacing.x = unit(1.2, "cm"),
        strip.text = element_text(size = 20, face = "bold")) +
  facet_wrap(~Year, scales = "free_x", nrow = 2, ncol = 1)

# Subset the needed columns
sub_2 <- subset(sub, select=c("G_S_00", "G_S_19", "Wood.Products"))
sub_2 <- sub_2 %>%
  rename(`2000`=G_S_00,
         `2019`=G_S_19,
         `Wood Products` = Wood.Products)
sub_gat <- gather(sub_2, key="Year", value="Effect", `2000`:`2019`)

sub_gat$`Wood Products` <- factor(sub_gat$`Wood Products`, 
                                levels = c("B", "UP", "UP+B", "Neither"))

# Plot the ridgeline 
c <- ggplot(sub_gat, aes(x = Effect, y = `Wood Products`, fill=`Wood Products`)) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01, alpha=0.2) +
  scale_fill_manual(name = "", values = c("UP" = "#F8766D", 
                                          "B" = "#00BFC4", 
                                          "UP+B" = "#619CFF",
                                          "Neither" = "#AAAAAA")) +
  labs(title = 'S-Influenced Growth Rate \nby Wood Products',
       x="Growth Rate Effect (%)") +
  xlim(-50,10) +
  theme_ipsum() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        axis.title.x = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        axis.title.y = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_blank(),
        legend.spacing.x = unit(1.2, "cm"),
        strip.text = element_text(size = 20, face = "bold")) +
  facet_wrap(~Year, scales = "free_x", nrow = 2, ncol = 1)

# Subset the needed columns
sub_2 <- subset(sub, select=c("S_S_00", "S_S_19", "Wood.Products"))
sub_2 <- sub_2 %>%
  rename(`2000`=S_S_00,
         `2019`=S_S_19,
         `Wood Products` = Wood.Products)
sub_gat <- gather(sub_2, key="Year", value="Effect", `2000`:`2019`)

sub_gat$`Wood Products` <- factor(sub_gat$`Wood Products`, 
                                levels = c("B", "UP", "UP+B", "Neither"))

# Plot the ridgeline 
d <- ggplot(sub_gat, aes(x = Effect, y = `Wood Products`, fill=`Wood Products`)) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01, alpha=0.2) +
  scale_fill_manual(name = "", values = c("UP" = "#F8766D", 
                                          "B" = "#00BFC4", 
                                          "UP+B" = "#619CFF", 
                                          "Neither" = "#AAAAAA")) +
  labs(title = 'S-Influenced Survival Rate \nby Wood Products',
       x="Survival Rate Effect (%)") +
  xlim(-35,5) +
  theme_ipsum() +
  theme(text = element_text(size = 18), 
        axis.text.x = element_text(size = 18, colour = "black"),
        axis.text.y = element_text(size = 18, colour = "black"),
        axis.title.x = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        axis.title.y = element_text(size = 20, face = "bold"), # Adjust the size of the x-axis title
        legend.text = element_text(size = 18, face = "bold"),
        axis.ticks=element_line(),
        plot.title = element_text(hjust=0.5, size = 18, face = "bold"),
        legend.position="bottom",
        panel.background = element_rect(colour = "white"),
        legend.key = element_blank(),
        legend.background = element_blank(),
        legend.spacing.x = unit(1.2, "cm"),
        strip.text = element_text(size = 20, face = "bold")) +
  facet_wrap(~Year, scales = "free_x", nrow = 2, ncol = 1)

# Generate the multi-panel figure
figure <- ggarrange(a,b,c,d,
                    labels=c("a", "b", "c", "d"),
                    ncol = 4, nrow = 1, legend = "bottom",
                    common.legend = TRUE)

# Export the figure
png("Extended_Data_Fig_2.png", height = 1000, width = 2000)
figure
dev.off()

# Export the figure as PDF
ggsave("Extended_Data_Fig_2.pdf", figure, height = 10, width = 20, units = "in", 
       dpi = 600)
# Timekeeping
toc()

## --------------------------- Script end --------------------------------------