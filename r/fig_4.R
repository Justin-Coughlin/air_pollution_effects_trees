## ------------------------ Script Information ---------------------------------
##
## Script name: fig_4.R
##
## Purpose of script: Generation of Fig 4 from Coughlin et al. (2023)
##
## Author: Justin G. Coughlin, M.S.
##
## Date Created: 2023-07-01
##
## Email: coughlin.justin@epa.gov
##
##
## Notes: These data were collected using funding from the U.S. 
## Government and can be used without additional permissions or fees. 
##
## Note: Removals of dataframes are continuous in this script 
## to keep the global environment clean
##
## Minimum RAM Needed: 16 GB
##
## ------------------------------ Fig 4 ----------------------------------------
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
# Growth-nitrogen
g_n_county <- read.csv("all_diff_dep_g_n_five_5per_1719.csv")
# Growth-sulfur
g_s_county <- read.csv("all_diff_dep_g_s_five_5per_1719.csv")
# Survival-nitrogen
s_n_county <- read.csv("all_diff_dep_s_n_one_5per_1719.csv")
# Survival-sulfur
s_s_county <- read.csv("all_diff_dep_s_s_one_5per_1719.csv")
# State-ecoregion join
eco <- read.csv("state_ecoregion_detailed.csv")
# Make suffix list
suffixes <- c(sprintf("%02d", 0:19), "0002", "0911", "1719")
# Timekeeping
toc()
tic("Process data and generate figures")


## ------------------------- Process data --------------------------------------
# Summarize state-ecoregion data
eco <- eco %>%
  group_by(STUSPS, NA_L1NAME, NA_L1CODE) %>%
  summarize(area = sum(Shape_Area),
            .groups = "keep") %>%
  group_by(STUSPS) %>%
  top_n(1, area)

# Summarize the sulfur data
# Survival-sulfur summary
s_s_county <- s_s_county %>%
  filter(!is.na(STATENS))
s_s_sub <- subset(s_s_county, select = c("STUSPS", "grid_code"))
s_s_sub <- s_s_sub %>%
  rename("Deposition" = "grid_code",
         "State" = "STUSPS") %>%
  mutate("Effect" = "Survival Rate")

# Growth-sulfur summary
g_s_county <- g_s_county %>%
  filter(!is.na(STATENS))
g_s_sub <- subset(g_s_county, select = c("STUSPS", "grid_code"))
g_s_sub <- g_s_sub %>%
  rename("Deposition" = "grid_code",
         "State" = "STUSPS") %>%
  mutate("Effect" = "Growth Rate")

# Join the two datasets
s_county_sub <- bind_rows(s_s_sub, g_s_sub)

# Calculate the median deposition 
s_county_sub_med <- s_county_sub %>%
  filter(Effect == "Growth Rate") %>%
  group_by(State) %>%
  summarise(medDep = median(Deposition, na.rm = TRUE))

# Join the median deposition data back to deposition reduction needed
s_county_sub <- left_join(s_county_sub, s_county_sub_med, by = "State")
# Join the ecoregion data
s_county_sub <- left_join(s_county_sub, eco, by = c("State"="STUSPS"))
# Order the data frame by NA1Code and medDep
s_county_sub <- s_county_sub %>% 
  mutate(ordering_var = paste(NA_L1CODE, medDep))

# Create ordering variables from existing data
x <- unique(s_county_sub$ordering_var)
y <- x[order(as.numeric(gsub("^(\\d+)\\s.*", "\\1", x)), 
             as.numeric(gsub("^\\d+\\s(.*)", "\\1", x)))]
# Create a new ordering variable
new_ordering_var <- seq_along(y)

# Join the ordering variable back to teh dataset
y_order <- NULL
y_order <- bind_cols("ordering_var"= y,"new_ordering_var" = new_ordering_var)
s_county_sub <- left_join(s_county_sub, y_order, by = "ordering_var")

# Create a new variable for the x-axis using as.numeric(as.factor())
s_county_sub$x_axis <- as.numeric(as.factor(s_county_sub$new_ordering_var))

# Create a cheat sheet
cheat <- subset(s_county_sub, select = c("State", "ordering_var",
                                         "new_ordering_var", "NA_L1CODE",
                                         "NA_L1NAME"))
cheat <- unique(cheat)

# Generate the sulfur deposition reduction needed plot
p <- ggplot(s_county_sub, aes(x=reorder(State, new_ordering_var), y=Deposition,
                              fill = Effect)) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 0,
           fill = "brown1", colour = "black", alpha = 0.1) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = Inf,
           fill = "cyan4", colour = "black", alpha = 0.1) +
  geom_boxplot(outlier.shape = NA, width = 1, position = position_dodge(width = 0.8)) +
  scale_x_discrete() +
  ylim(-5, 1) +
  labs(y = expression(Total~S~Deposition~(kg~S~ha^{-1}~yr^{-1})),
       title = "Sulfur Depositon", 
       fill = expression(bold("Deposition Change Needed \nto Protect 95% of Species"))) +
  annotate(geom="text", x=32.5, y=-4.5, label="Reduction \nNeeded",
           color="black", fontface = 2, size = 5) +
  annotate(geom="text", x=32.5, y=0.75, label="No \nReduction \nNeeded",
           color="black", fontface = 2, size = 5) +
  annotate(geom="text", x=49, y=-4.5, label="Mediterranean CA",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=46, y=-4.5, label="North American \nDeserts",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=38.5, y=-4.5, label="Great Plains",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=21.5, y=-4.5, label="Eastern \nTemperate \nForests",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=6, y=-4.5, label="Northwestern \nForested Mountains",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=2.5, y=-4.5, label="Northern Forests",
           color="black", fontface = 3, size = 4) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        plot.title = element_text(size = 18, face = "bold"),
        legend.text=element_text(size=18),
        axis.title.y=element_blank(),
        legend.key.width = unit(3.5, "cm"),
        legend.key.height = unit(1, "cm"),
        legend.position="bottom",
        legend.margin = margin(t = 20, r = 0, b = 10, l = 0),
        legend.title = element_text(margin = margin(t = 20)),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 14, colour = "black"),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())

# Offset the vertical lines by adding 0.5 to the x-coordinates
a <- p + geom_vline(xintercept =  c(4.5, 7.5, 34.5, 43.5, 48.5),
                    linetype = "dashed", color = "black", size = 0.5,
                    alpha = 0.5,
                    show.legend = FALSE)

# Flip the axes so the boxplots are vertical
a <- a + coord_flip() + scale_fill_manual(values=c("dodgerblue", "olivedrab"),
                                          labels=c(expression(~~~Delta~N[g5]~or~Delta~S[g5]),
                                                   expression(~~~Delta~N[s1]~or~Delta~S[s1])))


# Summarize the nitrogen data
# Survival-nitrogen summary
s_n_county <- s_n_county %>%
  filter(!is.na(STATENS))
s_n_sub <- subset(s_n_county, select = c("STUSPS", "grid_code"))
s_n_sub <- s_n_sub %>%
  rename("Deposition" = "grid_code",
         "State" = "STUSPS") %>%
  mutate("Effect" = "Survival Rate")

# Growth-nitrogen summary
g_n_county <- g_n_county %>%
  filter(!is.na(STATENS))
g_n_nub <- subset(g_n_county, select = c("STUSPS", "grid_code"))
g_n_nub <- g_n_nub %>%
  rename("Deposition" = "grid_code",
         "State" = "STUSPS") %>%
  mutate("Effect" = "Growth Rate")

# Join the two datasets
n_county_sub <- bind_rows(s_n_sub, g_n_nub)

# Calculate the median deposition for growth
n_county_sub_med <- n_county_sub %>%
  filter(Effect == "Survival Rate") %>%
  group_by(State) %>%
  summarise(medDep = median(Deposition, na.rm = TRUE),
            minDep = min(Deposition, na.rm = TRUE),
            maxDep = max(Deposition, na.rm = TRUE)) %>%
  mutate(Trend_med = ifelse(medDep>0, "Increasing", "Decreasing"),
         Trend_min = ifelse(minDep>0, "Increasing", "Decreasing"),
         Trend_max = ifelse(maxDep>0, "Increasing", "Decreasing"))

# Join the median deposition data back to deposition reduction needed
n_county_sub <- left_join(n_county_sub, n_county_sub_med, by = "State")
# Join the ecoregion data
n_county_sub <- left_join(n_county_sub, eco, by = c("State"="STUSPS"))
# Order the data frame by NA1Code and medDep
n_county_sub <- n_county_sub %>% 
  mutate(ordering_var = paste(NA_L1CODE, medDep))

# Create ordering variables from existing data
x <- unique(n_county_sub$ordering_var)
y <- x[order(as.numeric(gsub("^(\\d+)\\s.*", "\\1", x)), 
             as.numeric(gsub("^\\d+\\s(.*)", "\\1", x)))]

# Create a new ordering variable
new_ordering_var <- seq_along(y)

# Join the ordering variable back to teh dataset
y_order <- NULL
y_order <- bind_cols("ordering_var"= y,"new_ordering_var" = new_ordering_var)
n_county_sub <- left_join(n_county_sub, y_order, by = "ordering_var")

# Create a new variable for the x-axis using as.numeric(as.factor())
n_county_sub$x_axis <- as.numeric(as.factor(n_county_sub$new_ordering_var))

# Create a cheat sheet
cheat <- subset(n_county_sub, select = c("State", "ordering_var",
                                         "new_ordering_var", "NA_L1CODE",
                                         "NA_L1NAME"))
cheat <- unique(cheat)

# Generate the sulfur deposition reduction needed plot
p <- ggplot(n_county_sub, aes(x=reorder(State, new_ordering_var), y=Deposition,
                              fill = Effect)) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 0,
           fill = "brown1", colour = "black", alpha = 0.1) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = Inf,
           fill = "cyan4", colour = "black", alpha = 0.1) +
  geom_boxplot(outlier.shape = NA, width = 1, position = position_dodge(width = 0.8)) +
  scale_x_discrete() +
  ylim(-15, 20) +
  labs(y = expression(Total~N~Deposition~(kg~N~ha^{-1}~yr^{-1})),
       title = "Nitrogen Depositon", 
       fill = expression(bold("Deposition Change Needed \nto Protect 95% of Species"))) +
  annotate(geom="text", x=32.5, y=-12, label="Reduction \nNeeded",
           color="black", fontface = 2, size = 5) +
  annotate(geom="text", x=32.5, y=17.5, label="No \nReduction \nNeeded",
           color="black", fontface = 2, size = 5) +
  annotate(geom="text", x=49, y=-12, label="Mediterranean CA",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=46, y=-12, label="North American \nDeserts",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=38.5, y=-12, label="Great Plains",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=21.5, y=-12, label="Eastern \nTemperate \nForests",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=6, y=-12, label="Northwestern \nForested Mountains",
           color="black", fontface = 3, size = 4) +
  annotate(geom="text", x=2.5, y=-12, label="Northern Forests",
           color="black", fontface = 3, size = 4) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        plot.title = element_text(size = 18, face = "bold"),
        legend.text=element_text(size=18),
        axis.title.y=element_blank(),
        legend.key.width = unit(3.5, "cm"),
        legend.key.height = unit(1, "cm"),
        legend.position="bottom",
        legend.margin = margin(t = 20, r = 0, b = 10, l = 0),
        legend.title = element_text(margin = margin(t = 20)),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 14, colour = "black"),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())


# Offset the vertical lines by adding 0.5 to the x-coordinates
b <- p + geom_vline(xintercept =  c(4.5, 7.5, 34.5, 43.5, 48.5),
                    linetype = "dashed", color = "black", size = 0.5,
                    alpha = 0.5,
                    show.legend = FALSE)

# Flip the axes so the boxplots are vertical
b <- b + coord_flip() + scale_fill_manual(values=c("dodgerblue", "olivedrab"),
                                          labels=c(expression(~~~Delta~N[g5]~or~Delta~S[g5]),
                                                   expression(~~~Delta~N[s1]~or~Delta~S[s1])))


# Create dumby plot for legend
p <- ggplot(n_county_sub, aes(x=reorder(State, medDep), y=Deposition,
                              fill = Effect)) + 
  geom_boxplot(outlier.shape = NA) +
  scale_x_discrete(limits = rev(levels(n_county_sub$medDep))) +
  labs(y = expression(Total~N~Deposition~(kg~N~ha^{-1}~yr^{-1})),
       title = "Nitrogen Depositon", 
       fill = expression(bold("Deposition Change Needed \nto Protect 95% of Species"))) +
  theme_bw() +
  theme(text = element_text(size = 18), 
        plot.title = element_text(size = 18, face = "bold"),
        legend.text=element_text(size=18),
        axis.title.y=element_blank(),
        legend.key.width = unit(1.5, "cm"),
        legend.key.height = unit(1, "cm"),
        legend.position="bottom",
        legend.margin = margin(t = 20, r = 0, b = 10, l = 0),
        legend.title = element_text(margin = margin(t = 20)),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 14, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 14, colour = "black"),
        panel.grid.minor=element_blank(),
        panel.grid.major=element_blank())

# Flip the axes so the boxplots are vertical
c <- p + coord_flip() + scale_fill_manual(values=c("dodgerblue", "olivedrab"),
                                          labels=c(expression(~~~~~Delta~N[g5]~or~Delta~S[g5]),
                                                   expression(~~~~~Delta~N[s1]~or~Delta~S[s1])))
# Get the lengend
get_legend<-function(c){
  tmp <- ggplot_gtable(ggplot_build(c))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

# Extract the legend for the multi-panel plot
p2_legend <- get_legend(c)

# Generate the total multi-panel figure
figure <- ggarrange(b, a, labels = c("a", "b"), hjust = -1, vjust = 1.3,
                    font.label = list(size = 16, color = "black", face = "bold"),
                    common.legend = TRUE, legend.grob = p2_legend,
                    ncol = 2, nrow = 1, legend = "bottom")

# Export the figure
png("Fig_4.png", height = 1000, width = 1000)
figure
dev.off()

# Export the figure as PDF
ggsave("Fig_4.pdf", figure, height = 16, width = 16, units = "in", 
       dpi = 600)
# Timekeeping
toc()
# Timekeeping
toc()

## --------------------------- Script end --------------------------------------