
#### Load libraries ####
library(easypackages)
libraries("openair", "RColorBrewer", "ggplot2", "dplyr", "magrittr",
          "corrplot", "ggcorrplot", "psych", "EnvStats", "devtools",
          "graphics", "latticeExtra", "scales", "xlsx", "naniar",
          "data.table", "tidyr", "purrr", "Hmisc", "reshape2", "dplyr",
          "openxlsx", "zoo", "stargazer", "knitr", "tictoc", "tidyverse",
          "aqsr", "ggmap", "RAQSAPI", "anytime", "lubridate", "dplyr",
          "PerformanceAnalytics", "ggpubr", "readr", "ggpmisc", "foreign", "ggubr",
          "gridExtra", "cowplot", "ggalt", "hrbrthemes", "ggExtra", "stringr", 
          "broom", "ggfortify")

setwd("C:/Users/justi/OneDrive/Documents/Projects/20-Year Tree Effects/Data/Tree Effects")

hist <- read.csv("Histogram_forest_2.csv")

ggplot(hist, aes(x=Effect)) +
  geom_histogram(aes(y=..density..), position="identity", alpha=0.5)+
  geom_density(alpha=0.6)+
  scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
  scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
  labs(title="Weight histogram plot",x="Weight(kg)", y = "Density")+
  theme_classic()


ggplot(hist, aes(x=Effect)) +
  geom_histogram(position="identity", alpha=0.5)+
  scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
  scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9"))+
  labs(title="Weight histogram plot",x="Weight(kg)", y = "Count")+
  theme_classic()

p<-ggplot(hist, aes(x=Effect, y=Count)) +
  geom_bar()
p

ggplot(hist, aes(x=LABEL)) +
  geom_bar(y=hist$Count)

hist$Count <- as.numeric(hist$Count)

hist$Percent <- hist$Count/sum(hist$Count)*100

png("Basal Area Histogram.png", width = 800, height =800, res=250)

ggplot(hist, aes(x = Effect, y = Percent)) +
  geom_bar(aes(fill = Effect), stat = "identity") +
  scale_fill_gradientn(colors = c("burlywood4", "orange", "yellow", "lightgreen", "darkgreen"), 
                       values = rescale(c(-32, -16, -8, 0, 16, 84)),
                       guide = "none") +
  scale_x_continuous(limits = c(-32, 84), n.breaks = 12) +
  labs(x = expression(Basal ~ Area ~ Impact ~ (m^{2} ~ ha^{-2})), y = "Percent") +
  geom_vline(xintercept = 0, colour = "black", linetype = "dashed") +
  theme_bw() +
  theme(legend.position = "bottom",
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
        axis.ticks = element_line()) +
  coord_flip()

dev.off()



