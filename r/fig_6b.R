## ------------------------ Script Information ---------------------------------
##
## Script name: fig_6b.R
##
## Purpose of script: This script generates Fig 6b in Coughlin et al. (2023). 
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
          "tidyverse", "ggpubr", "purrr", "RColorBrewer", "scales",
          "hrbrthemes", "stringr", "broom", "ggfortify")
# Timekeeping
tic("Environment setting")

# Directory list
base_dir <- "C:/Users/justi/OneDrive/Documents" # Typically take base_dir to Docs/
file_dir <- file.path(base_dir, "Projects/20-Year Tree Effects/Data_Submission/process_files")
setwd(file_dir)
# Timekeeping
toc()
tic("Data processing")


## --------------------------- Load data ---------------------------------------
# Load output csv from ArcGIS
hist <- read.csv("basal_area_histogram.csv")
hist$Count <- as.numeric(hist$Count)
hist$Percent <- hist$Count/sum(hist$Count)*100

# Manually scale the color values
color_values <- scales::rescale(c(-32, -16, -8, 0, 16, 84))

# Generate a histogram of the basal area effect
p <- ggplot(hist, aes(x = Effect, y = Percent)) +
  geom_bar(aes(fill = Effect), stat = "identity") +
  scale_fill_gradientn(
    colours = c("burlywood4", "orange", "yellow", "lightgreen", "darkgreen"),
    values = color_values,
    guide = "none"
  ) +
  scale_x_continuous(limits = c(-32, 84), n.breaks = 12) +
  labs(x = expression(Basal ~ Area ~ Impact ~ (m^{2} ~ ha^{-2})), y = "Percent") +
  geom_vline(xintercept = 0, colour = "black", linetype = "dashed") +
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.box = "vertical",
    legend.title = element_blank(),
    legend.text = element_text(size = 12),
    text = element_text(size = 12, colour = "black"),
    axis.text.x = element_text(hjust = 1, size = 12, colour = "black"),
    axis.text.y = element_text(hjust = 1, size = 12, colour = "black"),
    axis.title.x = element_text(color = "black", size = 12),
    axis.title.y = element_text(color = "black", size = 12),
    plot.title = element_text(size = 12, face = "bold"),
    panel.border = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    axis.ticks = element_line()
  ) +
  coord_flip()

# Export the figure
png("Fig_6b.png", width = 800, height =800, res=250)
p
dev.off()

# Export the figure as PDF
ggsave("Fig_6b.pdf", p, height = 4, width = 4, units = "in", 
       dpi = 600)
# Timekeeping
toc()

## --------------------------- Script end --------------------------------------

