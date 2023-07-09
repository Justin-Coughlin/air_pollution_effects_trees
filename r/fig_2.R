## ------------------------ Script Information ---------------------------------
##
## Script name: fig_2.R
##
## Purpose of script: This script generates Fig 2 in Coughlin et al. (2023). 
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
          "tidyverse", "ggpubr", "purrr", "ggalt")
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
# Set themes to classic
theme_set(theme_classic())
# Percentile calculation of interest
p <- 0.05 # 5th percentile, change if interested in a different percentile
p_names <- paste0(p * 100, "%")
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% 
  set_names(nm = p_names)
# Timekeeping
toc()
tic("Make dumbbell plots")

## ------------------------ Sulfur dumbbells -----------------------------------
tree_effects$Wood.Products <- ifelse(is.na(tree_effects$Wood.Products), 
                                   "Neither", tree_effects$Wood.Products)

GS_State <- tree_effects %>%
  group_by(SPCD, Gen_Spp, Wood.Products, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(!!!p_funs))

## Create new names for the variables that are output from the function
oldnames = c("G_S_00_5%", "G_S_01_5%", "G_S_02_5%", "G_S_03_5%",
             "G_S_04_5%", "G_S_05_5%", "G_S_06_5%", "G_S_07_5%",
             "G_S_08_5%", "G_S_09_5%", "G_S_10_5%", "G_S_11_5%",
             "G_S_12_5%", "G_S_13_5%", "G_S_14_5%", "G_S_15_5%",
             "G_S_16_5%", "G_S_17_5%", "G_S_18_5%", "G_S_19_5%")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
GS_State <- GS_State %>% 
  rename_at(vars(oldnames), ~ newnames)
GS_State <- GS_State %>% mutate_all(na_if,"")
GS_State$SPCD <- GS_State$SPCD
GS_State <- GS_State %>% 
  drop_na(SPCD, Gen_Spp)
GS_sub <- subset(GS_State, select = c("SPCD", "Gen_Spp", 
                                              "pheno.type", "Wood.Products", 
                                              "2000", "2019"))
GS_sub$Gen_Spp <- factor(GS_sub$Gen_Spp, 
                             levels=as.character(GS_sub$Gen_Spp))  # for right ordering of the dumbells
GS_sub$p_2000 <- GS_sub$`2000`*100
GS_sub$p_2019 <- GS_sub$`2019`*100
GS_sub <- GS_sub %>%
  filter(!is.na(p_2000))

# Create a new variable that combines pheno.type and p_2000
GS_sub <- GS_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 
# Create a new ordering variable
GS_sub <- GS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create a new ordering variable
GS_sub <- GS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create the custom ordering for y-axis
y_order <- GS_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)
# Make the wood product column factors for plotting
GS_sub$Wood.Products <- factor(GS_sub$Wood.Products, 
                                      levels = c("B", "UP", 
                                                 "UP+B", "Neither"))

# Generate the growth-sulfur plot
a <- ggplot(GS_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=Wood.Products),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", 
                dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = GS_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  #limits = c("B", "UP", "B+UP", "Neither")) +
  xlim(-80, 17.5) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[40], x=-28, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[40], x=10, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[21.5], 
           ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 
             y_order[21.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[11], x=-60, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[35], x=-60, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "S-Influenced Growth Rate Effect",shape = expression(bold("Wood Products   ")),
       x = expression(Species-Level~Growth~Rate~Effect~(g(S,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", 
                                   face = "italic"),
        axis.title.y=element_blank(),
        axis.title.x=element_text(size = 16),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 18, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

# Make guides for plotting
a <- a + guides(shape = guide_legend(override.aes = list(size = 5, 
                                                         color="black")))

# Generate the survival-sulfur dataframe
SS_State <- tree_effects %>%
  group_by(SPCD, Gen_Spp, Wood.Products, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(!!!p_funs))

## Create new names for the variables that are output from the function
oldnames = c("S_S_00_5%", "S_S_01_5%", "S_S_02_5%", "S_S_03_5%",
             "S_S_04_5%", "S_S_05_5%", "S_S_06_5%", "S_S_07_5%",
             "S_S_08_5%", "S_S_09_5%", "S_S_10_5%", "S_S_11_5%",
             "S_S_12_5%", "S_S_13_5%", "S_S_14_5%", "S_S_15_5%",
             "S_S_16_5%", "S_S_17_5%", "S_S_18_5%", "S_S_19_5%")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
SS_State <- SS_State %>% 
  rename_at(vars(oldnames), ~ newnames)
SS_State <- SS_State %>% mutate_all(na_if,"")
SS_State$SPCD <- SS_State$SPCD
SS_State <- SS_State %>% 
  drop_na(SPCD, Gen_Spp)
SS_sub <- subset(SS_State, select = c("SPCD", "Gen_Spp", 
                                              "pheno.type", "Wood.Products", 
                                              "2000", "2019"))
SS_sub$Gen_Spp <- factor(SS_sub$Gen_Spp, 
                             levels=as.character(SS_sub$Gen_Spp))  # for right ordering of the dumbells
SS_sub$p_2000 <- SS_sub$`2000`*100
SS_sub$p_2019 <- SS_sub$`2019`*100
SS_sub <- SS_sub %>%
  filter(!is.na(p_2000))
# Create a new variable that combines pheno.type and p_2000
SS_sub <- SS_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 
# Create a new ordering variable
SS_sub <- SS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create a new ordering variable
SS_sub <- SS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create the custom ordering for y-axis
y_order <- SS_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)
# Make the wood product column factors for plotting
SS_sub$Wood.Products <- factor(SS_sub$Wood.Products, 
                                     levels = c("B", "UP", 
                                                "UP+B", "Neither"))

# Generate the survival-sulfur plot
b <- ggplot(SS_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=Wood.Products),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", 
                dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = SS_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  xlim(-50, 50) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[50], x=-15, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[50], x=13, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[21.5], 
           ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, 
           ymax = y_order[21.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[10], x=20, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[36], x=20, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "S-Influenced Survival Rate Effect",shape = expression(bold("Wood Products   ")),
       x = expression(Species-Level~Survival~Rate~Effect~(s(S,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", 
                                   face = "italic"),
        axis.title.y=element_blank(),
        axis.title.x=element_text(size = 16),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 18, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

# Make guides for plotting
b <- b + guides(shape = guide_legend(override.aes = list(size = 5, 
                                                         color="black")))
# Garbage collection
gc()
# Remove unnecessary dataframes
rm(GS_State, GS_sub, SS_State, SS_sub)


## ------------------------ Nitrogen dumbbells ---------------------------------
# Generate the growth-nitrogen dataframe
GN_State <- tree_effects %>%
  group_by(SPCD, Gen_Spp, Wood.Products, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(!!!p_funs))

## Create new names for the variables that are output from the function
oldnames = c("G_N_00_5%", "G_N_01_5%", "G_N_02_5%", "G_N_03_5%",
             "G_N_04_5%", "G_N_05_5%", "G_N_06_5%", "G_N_07_5%",
             "G_N_08_5%", "G_N_09_5%", "G_N_10_5%", "G_N_11_5%",
             "G_N_12_5%", "G_N_13_5%", "G_N_14_5%", "G_N_15_5%",
             "G_N_16_5%", "G_N_17_5%", "G_N_18_5%", "G_N_19_5%")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
GN_State <- GN_State %>% 
  rename_at(vars(oldnames), ~ newnames)
GN_State <- GN_State %>% mutate_all(na_if,"")
GN_State$SPCD <- GN_State$SPCD
GN_State <- GN_State %>% 
  drop_na(SPCD, Gen_Spp)
GN_sub <- subset(GN_State, select = c("SPCD", "Gen_Spp", 
                                              "pheno.type", "Wood.Products", "2000", "2019"))
GN_sub$Gen_Spp <- factor(GN_sub$Gen_Spp, 
                           levels=as.character(GN_sub$Gen_Spp))  # for right ordering of the dumbells
GN_sub$p_2000 <- GN_sub$`2000`*100
GN_sub$p_2019 <- GN_sub$`2019`*100
GN_sub <- GN_sub %>%
  filter(!is.na(p_2000))

# Create a new variable that combines pheno.type and p_2000
GN_sub <- GN_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 
# Create a new ordering variable
GN_sub <- GN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create a new ordering variable
GN_sub <- GN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create the custom ordering for y-axis
y_order <- GN_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)
# Make the wood product column factors for plotting
GN_sub$Wood.Products <- factor(GN_sub$Wood.Products, 
                                     levels = c("B", "UP", 
                                                "UP+B", "Neither"))
# Generate the growth-nitrogen plot
c <- ggplot(GN_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=Wood.Products),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", 
                dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = GN_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  xlim(-50, 75) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[51], x=55, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[51], x=8, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[25.5], 
           ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, 
           ymax = y_order[25.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[12], x=50, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[40], x=50, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[60], x=50, label="Off the Scale", size = 4,
           color="black", fontface = 2) +  
  annotate("segment", x = 25, xend = 75, y = y_order[59], yend = y_order[59],
           arrow = arrow(type = "closed", length = unit(0.02, "npc"))) +
  labs(title  = "N-Influenced Growth Rate Effect", shape = expression(bold("Wood Products   ")),
       x = expression(Species-Level~Growth~Rate~Effect~(g(N,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", 
                                   face = "italic"),
        axis.title.y=element_blank(),
        axis.title.x=element_text(size = 16),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 18, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

# Make guides for plotting
c <- c + guides(shape = guide_legend(override.aes = list(size = 5, 
                                                         color="black")))

# Generate the survival-nitrogen dataframe
SN_State <- tree_effects %>%
  group_by(SPCD, Gen_Spp, Wood.Products, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(!!!p_funs))

## Create new names for the variables that are output from the function
oldnames = c("S_N_00_5%", "S_N_01_5%", "S_N_02_5%", "S_N_03_5%",
             "S_N_04_5%", "S_N_05_5%", "S_N_06_5%", "S_N_07_5%",
             "S_N_08_5%", "S_N_09_5%", "S_N_10_5%", "S_N_11_5%",
             "S_N_12_5%", "S_N_13_5%", "S_N_14_5%", "S_N_15_5%",
             "S_N_16_5%", "S_N_17_5%", "S_N_18_5%", "S_N_19_5%")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
SN_State <- SN_State %>% 
  rename_at(vars(oldnames), ~ newnames)
SN_State <- SN_State %>% mutate_all(na_if,"")
SN_State$SPCD <- SN_State$SPCD
SN_State <- SN_State %>% 
  drop_na(Gen_Spp, SPCD)
SN_sub <- subset(SN_State, select = c("SPCD", "Gen_Spp", 
                                              "pheno.type", "Wood.Products", "2000", "2019"))

SN_sub$Gen_Spp <- factor(SN_sub$Gen_Spp, 
                             levels=as.character(SN_sub$Gen_Spp))  # for right ordering of the dumbells
SN_sub$p_2000 <- SN_sub$`2000`*100
SN_sub$p_2019 <- SN_sub$`2019`*100
SN_sub <- SN_sub %>%
  filter(!is.na(p_2000))
# Create a new variable that combines pheno.type and p_2000
SN_sub <- SN_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 
# Create a new ordering variable
SN_sub <- SN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create a new ordering variable
SN_sub <- SN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 
                                          1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()
# Create the custom ordering for y-axis
y_order <- SN_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)
# Make the wood product column factors for plotting
SN_sub$Wood.Products <- factor(SN_sub$Wood.Products, 
                                     levels = c("B", "UP", 
                                                "UP+B", "Neither"))
# Generate the survival-nitrogen plot
d <- ggplot(SN_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=Wood.Products),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", 
                dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = SN_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  xlim(-30, 50) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[39], x=-10, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[39], x=20, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[14.5], 
           ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, 
           ymax = y_order[14.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[7], x=20, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[28], x=20, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "N-Influenced Survival Rate Effect",shape = expression(bold("Wood Products   ")),
       x = expression(Species-Level~Survival~Effect~(s(N,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, 
                                   colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", 
                                   face = "italic"),
        axis.title.y=element_blank(),
        axis.title.x=element_text(size = 16),
        legend.title = element_text(size = 18),
        legend.text = element_text(size = 18, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 18, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

# Make guides for plotting
d <- d + guides(shape = guide_legend(override.aes = list(size = 5, 
                                                         color="black")))
# Generate the multi-panel figure
figure <- ggarrange(c, a, d, b, labels = c("a", "c", "b", "d"), 
                    hjust = -6, vjust = 1.2, common.legend = TRUE,
                    legend = "bottom",# Second row with box and dot plots
                    nrow = 2, ncol = 2) 

# Export the multi-panel figure
png("Fig_2.png", height = 1600, width = 1000)
figure
dev.off()

# Export the figure as PDF
ggsave("Fig_2.pdf", figure, height = 20, width = 14, units = "in", 
       dpi = 600)
# Timekeeping
toc()

## --------------------------- Script end --------------------------------------
