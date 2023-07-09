## ------------------------ Script Information ---------------------------------
##
## Script name: fig_1.R
##
## Purpose of script: This script generates Fig 1 in Coughlin et al. (2023). 
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
## Minimum RAM Needed: 16 GB
##
## ------------------------- Script Begin --------------------------------------
# Clear global environment
rm(list = ls(all.names = TRUE))

## ------------------ Load libraries and make directories ----------------------
library(easypackages)
libraries("ggplot2", "dplyr", "tidyr", "dplyr", "openxlsx", "tictoc", 
          "tidyverse", "ggpubr", "purrr")
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
# Make suffix list
suffixes <- c(sprintf("%02d", 0:19), "0002", "0911", "1719")
# Timekeeping
toc()
tic("Make functions")


## --------------------------- Functions ---------------------------------------
# Function to label figure
label_at <- function(n) function(x) ifelse(x %% n == 0, x, "")

# Get legend function for plotting
get_legend<-function(p){
  tmp <- ggplot_gtable(ggplot_build(p))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

# Percentile calculation of interest
p <- 0.05 # 5th percentile, change if interested in a different percentile
p_names <- paste0(p * 100, "%")
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% 
  set_names(nm = p_names)

# Function to rename columns for effects data
rename_effect_fun <- function(data, prefix) {
    # Create new names for the variables
    oldnames <- paste0(prefix, "_", )
    newnames <- 2000:2019
    
    rename_variables <- function(data, oldnames, newnames) {
      data %>% rename_with(~newnames, all_of(oldnames))
    }
}

# Function to rename columns for deposition data
rename_effect_fun <- function(data, prefix) {
  # Create new names for the variables
  oldnames <- paste0(prefix, "00:", prefix, "19")
  newnames <- 2000:2019
  
  rename_variables <- function(data, oldnames, newnames) {
    data %>% rename_with(~newnames, all_of(oldnames))
  }
}

# Common ggplot theme function
apply_common_theme <- function(plot) {
  plot +
    theme_bw() +
    theme(
      legend.position = "bottom",
      legend.box = "vertical",
      legend.title = element_text(size = 12, face="bold"),
      legend.text = element_text(size = 12),
      text = element_text(size = 12, colour = "black"),
      axis.text.x = element_text(hjust = 1, size = 12, colour = "black"),
      axis.text.y = element_text(hjust = 1, size = 12, colour = "black"),
      axis.title.x = element_text(color = "black", size = 12),
      axis.title.y = element_text(color = "black", size = 12),
      plot.title = element_text(size = 14, face = "bold"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      axis.ticks.length = unit(0.25, "cm"),
      axis.ticks = element_line()
    )
}
# Timekeeping
toc()
tic("Apply functions")


## --------------------- Summarize data for plotting ---------------------------
# Deposition data summaries
# Nitrogen deposition
N_Dep <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter(across(ends_with("Domain"), all_vars(. == 0))) %>%
  summarize(across(n_tw_20000:n_tw_20190, mean), .groups = "keep")

# Create new names for the variables that are output from the function
oldnames <- paste0("n_tw_", seq(19990, 20190, 10)[-1])
newnames <- as.character(2000:2019)

# Replace names
N_Dep <- N_Dep %>% 
  rename_at(vars(oldnames), ~ newnames)

# Flip it long to join to effects data
N_Dep_long <- gather(N_Dep, year, Ndep, "2000":"2019")
rm(N_Dep) # Remove N_Dep

# Sulfur deposition
S_Dep <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter(across(ends_with("Domain"), all_vars(. == 0))) %>%
  summarize(across(s_tw_20000:s_tw_20190, mean), .groups = "keep")

# Create new names for the variables that are output from the function
oldnames <- paste0("s_tw_", seq(19990, 20190, 10)[-1])
newnames <- as.character(2000:2019)

# Replace names
S_Dep <- S_Dep %>% 
  rename_at(vars(oldnames), ~ newnames)

# Flip it long to join to effects data
S_Dep_long <- gather(S_Dep, year, Sdep, "2000":"2019")
rm(S_Dep) # Remove S_Dep

# Effects summaries
# Nitrogen-growth rates
# Create new names for the variables that are output from the function
oldnames <- paste0("G_N_", sprintf("%02d", 0:19))
newnames <- as.character(2000:2019)

# Median
GN_Sum_med <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(median)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Create new names for the variables that are output from the function
oldnames <- paste0("G_N_", sprintf("%02d", 0:19), "_5%")
newnames <- as.character(2000:2019)
                         
# Fifth percentile
GN_Sum_fifth <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(!!!p_funs)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Sulfur-growth rates
# Create new names for the variables that are output from the function
oldnames <- paste0("G_S_", sprintf("%02d", 0:19))
newnames <- as.character(2000:2019)

# Median
GS_Sum_med <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(median)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Create new names for the variables that are output from the function
oldnames <- paste0("G_S_", sprintf("%02d", 0:19), "_5%")
newnames <- as.character(2000:2019)

# Fifth percentile
GS_Sum_fifth <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(!!!p_funs)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Nitrogen-survival rates
# Create new names for the variables that are output from the function
oldnames <- paste0("S_N_", sprintf("%02d", 0:19))
newnames <- as.character(2000:2019)

# Median
SN_Sum_med <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(median)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Create new names for the variables that are output from the function
oldnames <- paste0("S_N_", sprintf("%02d", 0:19), "_5%")
newnames <- as.character(2000:2019)

# Fifth percentile
SN_Sum_fifth <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(!!!p_funs)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Sulfur-survival rates
# Create new names for the variables that are output from the function
oldnames <- paste0("S_S_", sprintf("%02d", 0:19))
newnames <- as.character(2000:2019)

# Median
SS_Sum_med <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(median)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Create new names for the variables that are output from the function
oldnames <- paste0("S_S_", sprintf("%02d", 0:19), "_5%")
newnames <- as.character(2000:2019)

# Fifth percentile
SS_Sum_fifth <- tree_effects %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(!!!p_funs)) %>%
  rename_at(vars(oldnames), ~ newnames) %>%
  gather(., year, effect, "2000":"2019")

# Timekeeping
toc()
tic("Generate the figure")


## --------------------------- Create Fig 1 ------------------------------------
# The endpoint analyses 

# Growth - nitrogen analysis
tree_effects_GN <- GN_Sum_med %>%
  left_join(GN_Sum_fifth, by = c("SPCD", "Gen_Spp", "year")) %>%
  left_join(N_Dep_long, by = c("SPCD", "Gen_Spp", "year")) %>%
  rename(`Median Effect` = effect.x, `Fifth Percentile Effect` = effect.y) %>%
  gather(endpoint, effect, `Median Effect`:`Fifth Percentile Effect`) %>%
  mutate(year = as.numeric(year), effect = effect * 100)

# Create scaling parameters for plotting
ylim.NDep <- c(5, 19)
ylim.effect <- c(-30, 50)
a_gn <- 2.3
b_gn <- 0.3

# Generate the plot and hold in memory
f1 <- ggplot(tree_effects_GN, aes(x = year)) +
  annotate(geom = "rect", xmin = 2005, xmax = 2011, ymin = -Inf, 
           ymax = Inf, fill = "cadetblue4", alpha = 0.3) +
  annotate(geom = "rect", xmin = 2011, xmax = Inf, ymin = -Inf, 
           ymax = Inf, fill = "darkseagreen", alpha = 0.3) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = Ndep, group = "Fitted Line", fill = "Deposition"), 
              size = 0.75) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = a_gn + effect * b_gn, group = endpoint, fill = endpoint), 
              size = 0.75) +
  xlim(2000, 2020) +
  scale_y_continuous(sec.axis = sec_axis(~ (. - a_gn) / b_gn, 
                                         name = "Percent Effect")) +
  labs(y = expression(Total ~ N ~ Deposition ~ (kg ~ N ~ ha^{-1} ~ yr^{-1})), 
       x = "Year", title = "Interspecific N-Influenced Growth Effects") +
  scale_fill_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                    name = "Key") +
  scale_colour_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                      name = "Key") +
  annotate(geom = "text", x = 2008, y = 14.75, label = "CAIR", color = "black", 
           fontface = 2) +
  annotate(geom = "text", x = 2016, y = 14.75, label = "CSAPR/MATS", 
           color = "black", fontface = 2) 

# Apply common theme
f1 <- apply_common_theme(f1)

# Survival - Nitrogen
tree_effects_SN <- SN_Sum_med %>%
  left_join(SN_Sum_fifth, by = c("SPCD", "Gen_Spp", "year")) %>%
  left_join(N_Dep_long, by = c("SPCD", "Gen_Spp", "year")) %>%
  rename(`Median Effect` = effect.x, `Fifth Percentile Effect` = effect.y) %>%
  gather(endpoint, effect, `Median Effect`:`Fifth Percentile Effect`) %>%
  mutate(year = as.numeric(year), effect = effect * 100)

# Create scaling parameters for plotting
ylim.NDep <- c(1, 13)
ylim.effect <- c(-5, 5)
a_sn <- 10
b_sn <- 0.88

# Generate the plot and hold in memory
f2 <- ggplot(tree_effects_SN, aes(x = year)) +
  annotate(geom = "rect", xmin = 2005, xmax = 2011, ymin = -Inf, 
           ymax = Inf, fill = "cadetblue4", alpha = 0.3) +
  annotate(geom = "rect", xmin = 2011, xmax = Inf, ymin = -Inf, 
           ymax = Inf, fill = "darkseagreen", alpha = 0.3) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = Ndep, group = "Fitted Line", fill = "Deposition"), 
              size = 0.75) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = a_sn + effect * b_sn, group = endpoint, fill = endpoint), 
              size = 0.75) +
  xlim(2000, 2020) +
  scale_y_continuous(sec.axis = sec_axis(~ (. - a_sn) / b_sn, 
                                         name = "Percent Effect")) +
  labs(y = expression(Total ~ N ~ Deposition ~ (kg ~ N ~ ha^{-1} ~ yr^{-1})), 
       x = "Year", title = "Interspecific N-Influenced Survival Effects") +
  scale_fill_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                    name = "Key") +
  scale_colour_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                      name = "Key") +
  annotate(geom = "text", x = 2008, y = 15.35, label = "CAIR", color = "black", 
           fontface = 2) +
  annotate(geom = "text", x = 2016, y = 15.35, label = "CSAPR/MATS", 
           color = "black", fontface = 2)

# Apply common theme
f2 <- apply_common_theme(f2)

# Growth - Sulfur
tree_effects_GS <- GS_Sum_med %>%
  left_join(GS_Sum_fifth, by = c("SPCD", "Gen_Spp", "year")) %>%
  left_join(S_Dep_long, by = c("SPCD", "Gen_Spp", "year")) %>%
  rename(`Median Effect` = effect.x, `Fifth Percentile Effect` = effect.y) %>%
  gather(endpoint, effect, `Median Effect`:`Fifth Percentile Effect`) %>%
  mutate(year = as.numeric(year), effect = effect * 100)

# Create scaling parameters for plotting
ylim.Sdep <- c(1, 10)
ylim.effect <- c(-60, 0)
a_gs <- 5
b_gs <- 0.2

# Generate the plot and hold in memory
f3 <- ggplot(tree_effects_GS, aes(x = year)) +
  annotate(geom = "rect", xmin = 2005, xmax = 2011, ymin = -Inf, 
           ymax = Inf, fill = "cadetblue4", alpha = 0.3) +
  annotate(geom = "rect", xmin = 2011, xmax = Inf, ymin = -Inf, 
           ymax = Inf, fill = "darkseagreen", alpha = 0.3) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = Sdep, group = "Fitted Line", fill = "Deposition"), 
              size = 0.75) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = a_gs + effect * b_gs, group = endpoint, fill = endpoint), 
              size = 0.75) +
  xlim(2000, 2020) +
  scale_y_continuous(sec.axis = sec_axis(~ (. - a_gs) / b_gs, 
                                         name = "Percent Effect")) +
  labs(y = expression(Total ~ S ~ Deposition ~ (kg ~ S ~ ha^{-1} ~ yr^{-1})), 
       x = "Year", title = "Interspecific S-Influenced Growth Effects") +
  scale_fill_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                    name = "Key") +
  scale_colour_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                      name = "Key") +
  annotate(geom = "text", x = 2008, y = 10.2, label = "CAIR", color = "black", 
           fontface = 2) +
  annotate(geom = "text", x = 2016, y = 10.2, label = "CSAPR/MATS", 
           color = "black", fontface = 2) 

# Apply common theme
f3 <- apply_common_theme(f3)

# Survival - Sulfur
tree_effects_SS <- SS_Sum_med %>%
  left_join(SS_Sum_fifth, by = c("SPCD", "Gen_Spp", "year")) %>%
  left_join(S_Dep_long, by = c("SPCD", "Gen_Spp", "year")) %>%
  rename(`Median Effect` = effect.x, `Fifth Percentile Effect` = effect.y) %>%
  gather(endpoint, effect, `Median Effect`:`Fifth Percentile Effect`) %>%
  mutate(year = as.numeric(year), effect = effect * 100)

# Create scaling parameters for plotting
ylim.Sdep <- range(tree_effects_SS$Sdep)
ylim.effect <- range(tree_effects_SS$effect)
b_ss <- diff(ylim.Sdep) / diff(ylim.effect)
a_ss <- b_ss * (ylim.Sdep[1] - ylim.effect[1])
a_ss <- 8
b_ss <- 0.6

# Generate the plot and hold in memory
f4 <- ggplot(tree_effects_SS, aes(x = year)) +
  annotate(geom = "rect", xmin = 2005, xmax = 2011, ymin = -Inf, 
           ymax = Inf, fill = "cadetblue4", alpha = 0.3) +
  annotate(geom = "rect", xmin = 2011, xmax = Inf, ymin = -Inf, 
           ymax = Inf, fill = "darkseagreen", alpha = 0.3) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = Sdep, group = "Fitted Line", fill = "Deposition"), 
              size = 0.75) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = a_ss + effect * b_ss, group = endpoint, fill = endpoint), 
              size = 0.75) +
  xlim(2000, 2020) +
  scale_y_continuous(sec.axis = sec_axis(~ (. - a_ss) / b_ss, 
                                         name = "Percent Effect")) +
  labs(y = expression(Total ~ N ~ Deposition ~ (kg ~ N ~ ha^{-1} ~ yr^{-1})), 
       x = "Year", title = "Interspecific S-Influenced Survival Effects") +
  scale_fill_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                    name = "Key") +
  scale_colour_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                      name = "Key") +
  annotate(geom = "text", x = 2008, y = 10.2, label = "CAIR", color = "black", 
           fontface = 2) +
  annotate(geom = "text", x = 2016, y = 10.2, label = "CSAPR/MATS", 
           color = "black", fontface = 2) 

# Apply common theme
f4 <- apply_common_theme(f4)

# Create temporary plot to obtain legend for multi-panel plot
p <- ggplot(tree_effects_SS, aes(x=year)) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = Sdep, group = "Fitted Line", 
                  fill = "Deposition"), size = 0.75) +
  geom_smooth(method = "loess", colour = "black", se = TRUE, 
              aes(y = a_ss+effect*b_ss, group = endpoint, 
                  fill = endpoint), size = 0.75) +
  scale_fill_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                    name = "Key")  +
  scale_colour_manual(values = c("burlywood", "dodgerblue", "olivedrab"), 
                      name = "Key") 

# Apply common theme
p <- apply_common_theme(p)

# Access the legend and remove temp plot
p2_legend <- get_legend(p)
rm(p)

# Generate the multi-panel plot in memory to export
figure <- ggarrange(f1, f3, f2, f4, labels = c("a", "c", "b", "d"), 
                    common.legend = TRUE, legend.grob = p2_legend,
                    legend = "bottom", # Second row with box and dot plots
                    nrow = 2, ncol = 2) 

# Export fig 1
png("Fig_1.png", height = 700, width = 1000)
figure
dev.off()

# Export the figure as PDF
ggsave("Fig_1.pdf", figure, height = 7, width = 10, units = "in", 
       dpi = 600)

# Timekeeping
toc()

## --------------------------- Script end --------------------------------------