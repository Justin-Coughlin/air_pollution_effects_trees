## ------------------------ Script Information ---------------------------------
##
## Script name: calculate_temporal_effects.R
##
## Purpose of script: The purpose of this script is to use the raw data that
## contains the joined data from Horn et al. (2018) and the 2000-2019 NADP TDep
## surfaces of total N and S deposition. This scripts will export the dataset
## that is used to evaluate the plot-level data from FIA. Summary statistics tables
## are also calculated after processing has taken place.
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
## Note: Removals of dataframes are continuous in this script 
## to keep the global environment clean. The outline can be used for navigation.
##
## Minimum RAM Needed: 16 GB
##
## ------------------------- Script Begin --------------------------------------

# Clear global environment
rm(list = ls(all.names = TRUE))
# Timekeeping
tic("Environment setting")


## ------------------- Load libraries and create lists -------------------------
library(easypackages)
libraries("openair", "RColorBrewer", "ggplot2", "dplyr", "magrittr",
          "data.table", "tidyr", "purrr", "reshape2", "dplyr",
          "openxlsx", "tictoc", "tidyverse", "lubridate", "stringr")

# Percentile function
p <- 0.05 # Set percentile here, 5th percentile
p_names <- map_chr(p, ~paste0(.x*100, "%"))
p_funs <- map(p, ~partial(quantile, probs = .x, na.rm = TRUE)) %>% 
  set_names(nm = p_names) # Create new variable with 5th percentile in name

## Create series of functions to evaluate the percent effect for each tree
# TDep year suffix
suffixes <- c(sprintf("%02d", 0:19), "0002", "0911", "1719")
# Parameter-specific suffixes 
suffixes_n <- paste0("n_tw_20", suffixes, "0")
suffixes_s <- paste0("s_tw_20", suffixes, "0")

# Directory list
base_dir <- "C:/Users/justi/OneDrive/Documents" # Typically take base_dir to Docs/
file_dir <- file.path(base_dir, "Projects/20-Year Tree Effects/Data_Submission/process_files")
# Timekeeping
toc()
tic("Data loading and processing")


## --------------------------- Load data ---------------------------------------
# Pull in the RTI database with the joined TDep values (2000-2019)
setwd(file_dir)
Tree_Dep <- read.csv("tree_characteristic_deposition.csv")


## --------------------- Clean and analyze data --------------------------------
# This section will create new variables to ensure data filtering can be peformed
# throughout the process. Effects will also be evaluated.

# Change Dep@max columns to be 1000000000 
# if they are infinite to be included in calculations (monotonic increasers) 
value <- 1000000000 # Use a large number to stand for monotonic increase (e.g., Inf)
Tree_Dep <- Tree_Dep %>%
  mutate(Dep.max.g.N = ifelse(Shape.g.N=="increase" & is.na(Dep.max.g.N),
                              value, Dep.max.g.N),
         Dep.max.s.N = ifelse(Shape.s.N=="increase" & is.na(Dep.max.s.N),
                              value, Dep.max.s.N),
         Dep.max.g.S = ifelse(Shape.g.S=="increase" & is.na(Dep.max.g.S),
                              value, Dep.max.g.S),
         Dep.max.s.S = ifelse(Shape.s.S=="increase" & is.na(Dep.max.s.S),
                              value, Dep.max.s.S))

# Run the effects calculations for the four ecological endpoints
# Growth - nitrogen function
for (suffix in suffixes) {
  column_name <- paste0("G_N_", suffix)
  Tree_Dep[[column_name]] <- with(Tree_Dep, ifelse(Tree_Dep[[paste0("n_tw_20", suffix, "0")]] >= Dep.max.g.N,
                                                   exp(-0.5 * (log(Tree_Dep[[paste0("n_tw_20", suffix, "0")]] / g.n1) / g.n2)^2) / exp(-0.5 * (log(Dep.max.g.N / g.n1) / g.n2)^2) - 1,
                                                   exp(-0.5 * (log(Tree_Dep[[paste0("n_tw_20", suffix, "0")]] / g.n1) / g.n2)^2) / exp(-0.5 * (log(min_N / g.n1) / g.n2)^2) - 1
                                                   )
                                  )
                                                   
}

Tree_Dep <- bind_cols(Tree_Dep, lapply(suffixes, function(suffix) Tree_Dep[[suffix]]))

# Growth - sulfur function
for (suffix in suffixes) {
  column_name <- paste0("G_S_", suffix)
  Tree_Dep[[column_name]] <- with(Tree_Dep, ifelse(Tree_Dep[[paste0("s_tw_20", suffix, "0")]] >= Dep.max.g.S,
                                                   exp(-0.5 * (log(Tree_Dep[[paste0("s_tw_20", suffix, "0")]] / g.s1) / g.s2)^2) / exp(-0.5 * (log(Dep.max.g.S / g.s1) / g.s2)^2) - 1,
                                                   exp(-0.5 * (log(Tree_Dep[[paste0("s_tw_20", suffix, "0")]] / g.s1) / g.s2)^2) / exp(-0.5 * (log(min_S / g.s1) / g.s2)^2) - 1
  )
  )
  
}

Tree_Dep <- bind_cols(Tree_Dep, lapply(suffixes, function(suffix) Tree_Dep[[suffix]]))

# Survival - nitrogen function
for (suffix in suffixes) {
  column_name <- paste0("S_N_", suffix)
  Tree_Dep[[column_name]] <- with(Tree_Dep, ifelse(Tree_Dep[[paste0("n_tw_20", suffix, "0")]] >= Dep.max.s.N,
                                                   exp(-5 * (log(Tree_Dep[[paste0("n_tw_20", suffix, "0")]] / s.n1) / s.n2)^2) / exp(-5 * (log(Dep.max.s.N / s.n1) / s.n2)^2) - 1,
                                                   exp(-5 * (log(Tree_Dep[[paste0("n_tw_20", suffix, "0")]] / s.n1) / s.n2)^2) / exp(-5 * (log(min_N / s.n1) / s.n2)^2) - 1
  )
  )
  
}

Tree_Dep <- bind_cols(Tree_Dep, lapply(suffixes, function(suffix) Tree_Dep[[suffix]]))

# Survival - sulfur function
for (suffix in suffixes) {
  column_name <- paste0("S_S_", suffix)
  Tree_Dep[[column_name]] <- with(Tree_Dep, ifelse(Tree_Dep[[paste0("s_tw_20", suffix, "0")]] >= Dep.max.s.S,
                                                   exp(-5 * (log(Tree_Dep[[paste0("s_tw_20", suffix, "0")]] / s.s1) / s.s2)^2) / exp(-5 * (log(Dep.max.s.S / s.s1) / s.s2)^2) - 1,
                                                   exp(-5 * (log(Tree_Dep[[paste0("s_tw_20", suffix, "0")]] / s.s1) / s.s2)^2) / exp(-5 * (log(min_S / s.s1) / s.s2)^2) - 1
  )
  )
  
}

Tree_Dep <- bind_cols(Tree_Dep, lapply(suffixes, function(suffix) Tree_Dep[[suffix]]))

# Evaluate whether the observed deposition is within the domain of the response
# curve from Horn et al. (2018). A binary will be created for later use.

# Create new binary columns for domain of the response curve
Tree_Dep <- Tree_Dep %>%
  mutate(across(all_of(suffixes_n), ~ ifelse(. < min_N | . > max_N, 1, 0), 
                .names = "{.col}_Domain"),
         across(all_of(suffixes_s), ~ ifelse(. < min_S | . > max_S, 1, 0), 
                .names = "{.col}_Domain"))


## ---------------------- Export analyzed data  --------------------------------
Tree_Dep <- Tree_Dep %>%
  select(Gen_Spp, Genus, Species, Common.Name, SPCD, TRE_CN, PLT_CN, LAT, LON, 
         STUSPS, NAME, pheno.type, Wood.Products,
         starts_with("G_N_"), starts_with("G_S_"),
         starts_with("S_N_"), starts_with("S_S_"),
         ends_with("_Domain"))

# Clean global environment to free up memory
gc()

# Timekeeping
toc()
tic("Writing tree effects file")

write.csv(Tree_Dep, "tree_level_effects_2000_2019.csv")

# Timekeeping
tic()
toc("Species and state summaries")


## -------------------- Species export summaries -------------------------------
# Create median species summaries, domain of response curve filtering is done
# across all years to only include trees that have a full 20-year record

# Growth-nitrogen summary
GN_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(median))

# Growth-sulfur summary
GS_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(median))

# Survival-nitrogen summary
SN_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(median))

# Survival-sulfur summary
SS_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(median))

# Create a list of the datasets to export
list_of_data <- list("GN" = GN_Sum, "GS" = GS_Sum, 
                     "SN" = SN_Sum, "SS" = SS_Sum)

# Write xlsx 
write.xlsx(list_of_data, file = "species_median_trends.xlsx")

# Create fifth percentile species summaries, domain of response curve 
# filtering is done across all years to only include trees that have a 
# full 20-year record

# Growth-nitrogen summary
GN_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(!!!p_funs))

# Growth-sulfur summary
GS_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(!!!p_funs))

# Survival-nitrogen summary
SN_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(!!!p_funs))

# Survival-sulfur summary
SS_Sum <- Tree_Dep %>%
  group_by(SPCD, Gen_Spp) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(!!!p_funs))

# Create a list of the datasets to export
list_of_data <- list("GN" = GN_Sum, "GS" = GS_Sum, 
                     "SN" = SN_Sum, "SS" = SS_Sum)

# Write xlsx 
write.xlsx(list_of_data, file = "species_fifth_percentile_trends.xlsx")


## --------------------- State export summaries --------------------------------
# Create fifth percentile states summaries, domain of response curve 
# filtering is done across all years to only include trees that have a 
# full 20-year record

# Growth-nitrogen summary
GN_State <- Tree_Dep %>%
  group_by(STUSPS) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(!!!p_funs))

# Growth-sulfur summary
GS_State <- Tree_Dep %>%
  group_by(STUSPS) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(!!!p_funs))

# Survival-nitrogen summary
SN_State <- Tree_Dep %>%
  group_by(STUSPS) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(!!!p_funs))

# Survival-sulfur summary
SS_State <- Tree_Dep %>%
  group_by(STUSPS) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(!!!p_funs))

# Create a list of the datasets to export
list_of_data <- list("GN" = GN_State, "GS" = GS_State, 
                     "SN" = SN_State, "SS" = SS_State)

# Write xlsx 
write.xlsx(list_of_data, file = "state_fifth_percentile_trends.xlsx")
# Timekeeping
toc()

## --------------------------- Script end --------------------------------------