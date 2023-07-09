## ------------------------ Script Information ---------------------------------
##
## Script name: fig_5.R
##
## Purpose of script: This script generates Fig 5a-d in Coughlin et al. (2023). 
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
## Note: tree_characteristic_deposition.csv is needed for this script.
##
## Minimum RAM Needed: 16 GB
##
## ------------------------- Script Begin --------------------------------------
# Clear global environment
rm(list = ls(all.names = TRUE))

## ------------------ Load libraries and make directories ----------------------
library(easypackages)
libraries("ggplot2", "dplyr", "tidyr", "dplyr", "openxlsx", "tictoc", 
          "tidyverse", "ggpubr", "purrr", "RColorBrewer")
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
# Effects dataset
tree_dep <- read.csv("tree_characteristic_deposition.csv")
# Subset the effects dataset
tree_dep <- subset(tree_dep, select = c("SPCD", "Gen_Spp", "LAT", "LON", 
                                        "PLT_CN", "g.n1", "g.n2", "Dep.max.g.N", 
                                        "s.n1", "s.n2", "Dep.max.s.N", "min_N", 
                                        "max_N", "Shape.g.N", "Shape.s.N",
                                        "noxi_tw_2017190", "nred_tw_2017190",
                                        "n_tw_2017190"))
# Oxidized and reduced N deposition dataset
ox_red <- read.csv("n_ox_red_comparison.csv")
# Conduct a join so the raster-extracted files are joined to the tree_dep file
tree_dep <- left_join(tree_dep, ox_red, by = c("LAT" = "LAT", "LON" = "LON"),
                       relationship = "many-to-many")

# Percentile calculation of interest
p <- 0.05 # 5th percentile, change if interested in a different percentile
p_names <- paste0(p * 100, "%")
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% 
  set_names(nm = p_names)
# Timekeeping
toc()
tic("Process data")

## -------------------------- Process data -------------------------------------
# Evaluate the deposition reduction needed to prevent a 5% (growth) and 
# 1% (survival reduction) - in the equations, the 1-x is the location where
# other reductions can be evaluated. For example, 1-0.05 evaluates a 
# deposition level to prevent a 5% reduction
tree_dep <- tree_dep %>%
  mutate(G_N_new = ifelse(Shape.g.N == "decreasing" | Shape.g.N == "unimodal",
                          g.n1*exp(sqrt(-2*log(1-0.05)*g.n2^2+log(Dep.max.g.N/g.n1)^2)),
                          ifelse(Shape.g.N == "flat", NA,
                                 g.n1*exp(sqrt(-2*log(1-0.05)*g.n2^2+log(min_N/g.n1)^2)))),
         S_N_new = ifelse(Shape.s.N == "decreasing" | Shape.s.N == "unimodal",
                          s.n1*exp(sqrt((-2*log(1-0.01)*s.n2^2)/10+log(Dep.max.s.N/s.n1)^2)),
                          ifelse(Shape.s.N == "flat", NA,
                                 s.n1*exp(sqrt((-2*log(1-0.01)*s.n2^2)/10+log(min_N/s.n1)^2))))) 

# Limit the evaluation to only situations where the deposition is within
# the domain of the original response curve
tree_dep <- tree_dep %>%
  mutate(G_N_new = ifelse(G_N_new < min_N | G_N_new > max_N, NA, G_N_new),
         S_N_new = ifelse(S_N_new < min_N | S_N_new > max_N, NA, S_N_new))

# Calculate the difference from the amount of N deposition needed versus
# what is being experienced in 2017-2019
tree_dep <- tree_dep %>%
  mutate(G_N_reduction = G_N_new - n_tw_2017190,
         S_N_reduction = S_N_new - n_tw_2017190) 

# Change the number of digits for plotting purposes
ox_red$nred_tw_1719 <- ifelse(is.na(ox_red$nred_tw_1719), 
                              NA, formatC(ox_red$nred_tw_1719, 
                                          digits = 1, format = "f"))
ox_red$noxi_tw_1719 <- ifelse(is.na(ox_red$noxi_tw_1719), 
                              NA, formatC(ox_red$noxi_tw_1719, 
                                          digits = 1, format = "f"))

# Filter situations where ox. and red. N deposition are not NA
ox_red <- ox_red %>%
  filter(nred_tw_1719!="NA" | noxi_tw_1719 != "NA") 
# Create a new combination N deposition
ox_red$NDep_combo <- paste(ox_red$nred_tw_1719, ox_red$noxi_tw_1719, sep=",")
# Subset the necessary columns
ox_red_sub <- subset(ox_red, select = c("LAT", "LON", "NDep_combo"))
# Join back to the main dataframe
tree_dep <- left_join(tree_dep, ox_red_sub, by = c("LAT" = "LAT", "LON" = "LON"),
                       relationship = "many-to-many")
# Generate a summary of the fifth percentile reductions needed
ox_red_sum <- tree_dep %>%
  group_by(LAT, LON, NDep_combo) %>%
  summarize_at(vars(G_N_reduction:S_N_reduction), funs(!!!p_funs)) 

# Generate a N deposition summary to determine the median
NDep_sum <- ox_red_sum %>%
  group_by(NDep_combo) %>%
  summarise(G_N_median = median(`G_N_reduction_5%`, na.rm = TRUE),
            S_N_median = median(`S_N_reduction_5%`, na.rm = TRUE)) %>%
  mutate_all(~ ifelse(is.nan(.), NA, .))

# Join deposition summary back to the total summary 
ox_red_sum <- left_join(ox_red_sum, NDep_sum, by = "NDep_combo")

# Make all columns numeric
ox_red[,1:9] <- sapply(ox_red[,1:9],as.numeric)
# Join summary data back to the main
ox_red <- left_join(ox_red, ox_red_sum, by = c("LAT" = "LAT", "LON" = "LON"))
# Rename the median 5th percentile median column
ox_red$G_N_dep <- ox_red$G_N_median
ox_red$S_N_dep <- ox_red$S_N_median

# Create breaks for plotting
ox_red <- ox_red %>% 
  mutate(s_n_bin = cut(S_N_dep, breaks=c(-20, -10, -5, -2.5, -1, 
                                         0, 1, 2.5, 5, 30)))
ox_red <-ox_red %>% 
  mutate(g_n_bin = cut(G_N_dep, breaks=c(-20, -10, -5, -2.5, -1, 
                                         0, 1, 2.5, 5, 30)))

# Filter the data that is needed in a new dataframe
ox_red_fig <- subset(ox_red, select = c("PLT_CN", "noxi_tw_1719", "nred_tw_1719",
                                        "G_N_dep", "S_N_dep", "s_n_bin", 
                                        "g_n_bin"))

# Format the data for plotting purposes
ox_red_fig$G_N_dep <- formatC(ox_red_fig$G_N_dep, digits = 1, format = "f")
ox_red_fig$S_N_dep <- formatC(ox_red_fig$S_N_dep, digits = 1, format = "f")
ox_red_fig$nred_tw_1719 <- formatC(ox_red_fig$nred_tw_1719, 
                                   digits = 1, format = "f")
ox_red_fig$noxi_tw_1719 <- formatC(ox_red_fig$noxi_tw_1719, 
                                   digits = 1, format = "f")
# Make no response names for NAs
ox_red_fig$g_n_bin <- factor(ox_red_fig$g_n_bin, 
                             levels = c(levels(ox_red_fig$g_n_bin), 
                                        "No response"))
ox_red_fig[which(is.na(ox_red_fig$g_n_bin)), "g_n_bin"] <- "No response"
ox_red_fig$s_n_bin <- factor(ox_red_fig$s_n_bin, 
                             levels = c(levels(ox_red_fig$s_n_bin), 
                                        "No response"))
ox_red_fig[which(is.na(ox_red_fig$s_n_bin)), "s_n_bin"] <- "No response"

# Make columns numeric that are needed for plotting
ox_red_fig[,1:5] <- sapply(ox_red_fig[,1:5],as.numeric)
# Timekeeping
toc()
tic("Make figure")

## --------------------------- Plot figure -------------------------------------
# Generate a label for the plot
label1 <- expression(Delta~N[s1])

# Plot the survival-nitrogen figure and store in memory
a <- ox_red_fig %>%
  filter(!is.na(s_n_bin)) %>%
  ggplot(., aes(noxi_tw_1719, nred_tw_1719, z = S_N_dep)) +
  geom_raster(aes(fill = factor(s_n_bin))) +
  geom_contour(colour = "white") +
  scale_y_continuous(limits = c(0,12), position = "right") +
  xlim(0,10) +
  labs(y = expression(Reduced~N~Deposition~(kg~N~ha^{-1}~yr^{-1})),
       x = expression(Oxidized~N~Deposition~(kg~N~ha^{-1}~yr^{-1})),
       fill = expression(bold("Deposition Change Needed\nto Protect 95% of Trees (kg N ha"^{-1} * "yr"^{-1} * ")"))
  ) +
  scale_fill_manual(
    values = c("#b2182b", "#d6604d", "#f4a582", "#fddbc7",
               "#f7f7f7", "#d1e5f0", "#4393c3", "#2166ac", "#053061", "grey")
  ) +
  annotate(geom = "text", x = 1, y = 10, label = label1, parse = TRUE,
           color = "black", fontface = 2, size = 6) + 
  annotate(geom = "text", x = 1, y = 11, label = "Survival Rate",
           color = "black", fontface = 2, size = 6) + 
  geom_point(x = 5, y = 5, size = 4, color = "black") +
  annotate(
    "segment", x = 5, xend = 2.5, y = 5, yend = 5, colour = "black",
    linewidth = 1.5, arrow = arrow()
  ) +
  annotate(
    "segment", x = 5, xend = 5, y = 5, yend = 2.5, colour = "black",
    linewidth = 1.5, arrow = arrow()
  ) +
  geom_curve(
    aes(x = 2.5, y = 5, xend = 5, yend = 2.5), color = "black",
    linetype = "dashed", linewidth = 1.5
  ) +
  theme_bw() +
  theme(
    text = element_text(size = 14), 
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14, 
                               colour = "black"),
    axis.text.y = element_text(hjust = 1, size = 14, colour = "black"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.spacing.x = unit(1.0, 'cm'),
    axis.ticks = element_line(),
    legend.position = "bottom",
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 14, face = "bold"),
    panel.border = element_blank()
  )

# Generate a label for the plot
label1<- expression(Delta~N[g5])

# Plot the growth-nitrogen figure and store in memory
b <- ox_red_fig %>%
  filter(!is.na(g_n_bin)) %>%
  ggplot(., aes(noxi_tw_1719, nred_tw_1719, z = G_N_dep)) +
  geom_raster(aes(fill = factor(g_n_bin))) +
  geom_contour(colour = "white") +
  xlim(0,10) +
  labs(y = expression(Reduced~N~Deposition~(kg~N~ha^{-1}~yr^{-1})),
       x = expression(Oxidized~N~Deposition~(kg~N~ha^{-1}~yr^{-1})),
       fill = expression(bold("Deposition Change Needed\nto Protect 95% of Trees (kg N ha"^{-1} * "yr"^{-1} * ")"))
  ) +
  scale_fill_manual(
    values = c("#b2182b", "#d6604d", "#f4a582", "#fddbc7",
               "#f7f7f7", "#d1e5f0", "#4393c3", "#2166ac", "#053061", "grey")
  ) +
  scale_y_continuous(limits = c(0,12), position = "left") +
  annotate(geom = "text", x = 1, y = 10, label = label1, parse = TRUE,
           color = "black", fontface = 2, size = 6) + 
  annotate(geom = "text", x = 1, y = 11, label = "Growth Rate",
           color = "black", fontface = 2, size = 6) + 
  theme_bw() +
  theme(
    text = element_text(size = 14), 
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14, 
                               colour = "black"),
    axis.text.y = element_text(hjust = 1, size = 14, colour = "black"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.spacing.x = unit(1.0, 'cm'),
    axis.ticks = element_line(),
    legend.position = "bottom",
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 14, face = "bold"),
    panel.border = element_blank()
  )

# Rework the dataset to plot histograms of ox. and red. N deposition
ox_red_sub <- subset(ox_red, select = c("PLT_CN", "noxi_tw_1719", 
                                        "nred_tw_1719"))
ox_red_sub <- ox_red_sub %>% # Rename for plotting
  rename("Oxidized" = "noxi_tw_1719",
         "Reduced" = "nred_tw_1719")
# Flip long for plotting
ox_red_long <- gather(ox_red_sub, Form, Deposition, "Oxidized":"Reduced")
ox_red_long$Deposition <- as.numeric(ox_red_long$Deposition)
# Create the deposition histogram
c <- ggplot(ox_red_long, aes(Deposition, fill = Form, colour = Form)) +
  geom_density(alpha = 0.4) +
  xlim(0, 10) +
  scale_fill_manual(values = c("tomato1", "goldenrod1")) +
  annotate(geom="text", y=0.19, x=7.55, label="Oxidized",
           color="tomato1", fontface = 2, size =4) +
  annotate(geom="text", y=0.3, x=3, label="Reduced",
           color="goldenrod1", fontface = 2, size = 4) +    
  scale_y_continuous(position = "right") +
  annotate(geom="text", x=8.5, y=0.1, 
           label="Oxidized and Reduced \n Nitrogen Deposition",
           color="black", fontface = 2, size = 6) +
  labs(y = "Frequency",
       x = expression(N~Deposition~(kg~N~ha^{-1}~yr^{-1}))) +
  annotate("segment", x = 7.15, xend = 5.3, y = 0.19, yend = 0.19, 
           colour = "tomato1") +
  annotate("segment", x = 3, xend = 3, y = 0.28, yend = 0.23, colour = "goldenrod1") +
  theme_bw() +
  theme(text = element_text(size = 14), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 14, colour = "black"),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank(),
        legend.position="none",
        axis.ticks=element_line(),
        panel.border=element_blank())

# Create the multi-panel figure
figure <- ggarrange(c, ggarrange(b, a, labels = c("b", "c"),
                                common.legend = TRUE, legend = "bottom",
                                font.label = list(size = 16)),
                    nrow = 2, heights = c(0.5, 1, 1),
                    labels = "a",
                    font.label = list(size = 16))

# Export the figure
png("Fig_5a-d.png", height = 775, width = 1000)
figure
dev.off()

# Export the figure as PDF
ggsave("Fig_5a-d.pdf", figure, height = 10, width = 14, units = "in", 
       dpi = 600)
# Timekeeping
toc()

## --------------------------- Script end --------------------------------------