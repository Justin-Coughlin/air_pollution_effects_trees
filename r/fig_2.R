
################ Species Level Dumbbell ########################################
#### 5th percentile ####

# assuming RTI_States is the name of your dataframe
RTI_States <- RTI_States[, -c(100:144)]

#### Sulfur Dumbbell Plots

RTI_States$`Wood Products` <- ifelse(is.na(RTI_States$`Wood Products`), "Neither", RTI_States$`Wood Products`)

RTI_GS_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, `Wood Products`, pheno.type) %>%
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
RTI_GS_State <- RTI_GS_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_GS_State <- RTI_GS_State %>% mutate_all(na_if,"")

RTI_GS_State$SPCD <- RTI_GS_State$spp_code

RTI_GS_State <- RTI_GS_State %>% 
  drop_na(SPCD, Gen_Spp)

RTI_GS_sub <- subset(RTI_GS_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "Wood Products", "2000", "2019"))

RTI_GS_sub$Gen_Spp <- factor(RTI_GS_sub$Gen_Spp, levels=as.character(RTI_GS_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_GS_sub$p_2000 <- RTI_GS_sub$`2000`*100
RTI_GS_sub$p_2019 <- RTI_GS_sub$`2019`*100

theme_set(theme_classic())

RTI_GS_sub <- RTI_GS_sub %>%
  filter(!is.na(p_2000))

library(ggalt)

# Create a new variable that combines pheno.type and p_2000
RTI_GS_sub <- RTI_GS_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_GS_sub <- RTI_GS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_GS_sub <- RTI_GS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_GS_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

RTI_GS_sub$`Wood Products` <- factor(RTI_GS_sub$`Wood Products`, 
                                      levels = c("B", "UP", "UP+B", "Neither"))

a <- ggplot(RTI_GS_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=`Wood Products`),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_GS_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  #limits = c("B", "UP", "B+UP", "Neither")) +
  xlim(-80, 17.5) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[40], x=-28, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[40], x=10, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[21.5], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[21.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[11], x=-60, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[35], x=-60, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "S-Influenced Growth Rate Effect", shape = "Wood Products   ",
       x = expression(Species-Level~Growth~Rate~Effect~(g(S,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

a <- a + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
a

RTI_SS_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, `Wood Products`, pheno.type) %>%
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
RTI_SS_State <- RTI_SS_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_SS_State <- RTI_SS_State %>% mutate_all(na_if,"")
RTI_SS_State$SPCD <- RTI_SS_State$spp_code

RTI_SS_State <- RTI_SS_State %>% 
  drop_na(SPCD, Gen_Spp)

RTI_SS_sub <- subset(RTI_SS_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "Wood Products", "2000", "2019"))

RTI_SS_sub$Gen_Spp <- factor(RTI_SS_sub$Gen_Spp, levels=as.character(RTI_SS_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_SS_sub$p_2000 <- RTI_SS_sub$`2000`*100
RTI_SS_sub$p_2019 <- RTI_SS_sub$`2019`*100

theme_set(theme_classic())

RTI_SS_sub <- RTI_SS_sub %>%
  filter(!is.na(p_2000))

# Create a new variable that combines pheno.type and p_2000
RTI_SS_sub <- RTI_SS_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_SS_sub <- RTI_SS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_SS_sub <- RTI_SS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_SS_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

RTI_SS_sub$`Wood Products` <- factor(RTI_SS_sub$`Wood Products`, 
                                     levels = c("B", "UP", "UP+B", "Neither"))

b <- ggplot(RTI_SS_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=`Wood Products`),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_SS_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  xlim(-50, 50) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[50], x=-15, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[50], x=13, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[21.5], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[21.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[10], x=20, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[36], x=20, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "S-Influenced Survival Rate Effect",shape = "Wood Products   ",
       x = expression(Species-Level~Survival~Rate~Effect~(s(S,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

b <- b + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
b
gc()
rm(RTI_GS_State, RTI_GS_sub, RTI_SS_State, RTI_SS_sub)
#### Nitrogen Dumbbell Plots

RTI_GN_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, `Wood Products`, pheno.type) %>%
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
RTI_GN_State <- RTI_GN_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_GN_State <- RTI_GN_State %>% mutate_all(na_if,"")
RTI_GN_State$SPCD <- RTI_GN_State$spp_code

RTI_GN_State <- RTI_GN_State %>% 
  drop_na(SPCD, Gen_Spp)

RTI_GN_sub <- subset(RTI_GN_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "Wood Products", "2000", "2019"))

RTI_GN_sub$Gen_Spp <- factor(RTI_GN_sub$Gen_Spp, levels=as.character(RTI_GN_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_GN_sub$p_2000 <- RTI_GN_sub$`2000`*100
RTI_GN_sub$p_2019 <- RTI_GN_sub$`2019`*100

RTI_GN_sub <- RTI_GN_sub %>%
  filter(!is.na(p_2000))

theme_set(theme_classic())

# Create a new variable that combines pheno.type and p_2000
RTI_GN_sub <- RTI_GN_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_GN_sub <- RTI_GN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_GN_sub <- RTI_GN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_GN_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

RTI_GN_sub$`Wood Products` <- factor(RTI_GN_sub$`Wood Products`, 
                                     levels = c("B", "UP", "UP+B", "Neither"))

c <- ggplot(RTI_GN_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=`Wood Products`),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_GN_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  xlim(-50, 75) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[51], x=55, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[51], x=8, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[25.5], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[25.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[12], x=50, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[40], x=50, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[60], x=50, label="Off the Scale", size = 4,
           color="black", fontface = 2) +  
  annotate("segment", x = 25, xend = 75, y = y_order[59], yend = y_order[59],
           arrow = arrow(type = "closed", length = unit(0.02, "npc"))) +
  labs(title  = "N-Influenced Growth Rate Effect", shape = "Wood Products   ",
       x = expression(Species-Level~Growth~Rate~Effect~(g(N,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

c <- c + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
c

RTI_SN_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, `Wood Products`, pheno.type) %>%
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
RTI_SN_State <- RTI_SN_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_SN_State <- RTI_SN_State %>% mutate_all(na_if,"")
RTI_SN_State$SPCD <- RTI_SN_State$spp_code

RTI_SN_State <- RTI_SN_State %>% 
  drop_na(Gen_Spp, SPCD)

RTI_SN_sub <- subset(RTI_SN_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "Wood Products", "2000", "2019"))

RTI_SN_sub$Gen_Spp <- factor(RTI_SN_sub$Gen_Spp, levels=as.character(RTI_SN_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_SN_sub$p_2000 <- RTI_SN_sub$`2000`*100
RTI_SN_sub$p_2019 <- RTI_SN_sub$`2019`*100

RTI_SN_sub <- RTI_SN_sub %>%
  filter(!is.na(p_2000))

theme_set(theme_classic())

# Create a new variable that combines pheno.type and p_2000
RTI_SN_sub <- RTI_SN_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_SN_sub <- RTI_SN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_SN_sub <- RTI_SN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 + p_2000, 2000000 + p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_SN_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

RTI_SN_sub$`Wood Products` <- factor(RTI_SN_sub$`Wood Products`, 
                                     levels = c("B", "UP", "UP+B", "Neither"))

d <- ggplot(RTI_SN_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=`Wood Products`),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_SN_sub$Gen_Spp) +
  scale_shape_manual(values = c(15, 17, 19, 25)) +
  xlim(-30, 50) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[39], x=-10, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[39], x=20, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[14.5], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[14.5],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[7], x=20, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[28], x=20, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "N-Influenced Survival Rate Effect",shape = "Wood Products    ",
       x = expression(Species-Level~Survival~Effect~(s(N,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

d <- d + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
d
figure <- ggarrange(c, a, d, b, labels = c("a", "c", "b", "d"), 
                    hjust = -6, vjust = 1.2, common.legend = TRUE,
                    legend = "bottom",# Second row with box and dot plots
                    nrow = 2, ncol = 2) 

png("Species Fifth Percentile Dumbbell.png", height = 1400, width = 900)

figure

dev.off()

#### Median ####

#### Sulfur Dumbbell Plots

RTI_GS_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, myco, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_S_00:G_S_19), funs(median), na.rm = TRUE)

## Create new names for the variables that are output from the function
oldnames = c("G_S_00", "G_S_01", "G_S_02", "G_S_03",
             "G_S_04", "G_S_05", "G_S_06", "G_S_07",
             "G_S_08", "G_S_09", "G_S_10", "G_S_11",
             "G_S_12", "G_S_13", "G_S_14", "G_S_15",
             "G_S_16", "G_S_17", "G_S_18", "G_S_19")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")


## Rename the variables 
RTI_GS_State <- RTI_GS_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_GS_State <- RTI_GS_State %>% mutate_all(na_if,"")

RTI_GS_State$SPCD <- RTI_GS_State$spp_code

RTI_GS_State <- RTI_GS_State %>% 
  drop_na(SPCD, Gen_Spp)

RTI_GS_sub <- subset(RTI_GS_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "myco", "2000", "2019"))

RTI_GS_sub$Gen_Spp <- factor(RTI_GS_sub$Gen_Spp, levels=as.character(RTI_GS_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_GS_sub$p_2000 <- RTI_GS_sub$`2000`*100
RTI_GS_sub$p_2019 <- RTI_GS_sub$`2019`*100

theme_set(theme_classic())

RTI_GS_sub <- RTI_GS_sub %>%
  filter(!is.na(p_2000))

library(ggalt)

# Create a new variable that combines pheno.type and p_2000
RTI_GS_sub <- RTI_GS_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_GS_sub <- RTI_GS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_GS_sub <- RTI_GS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_GS_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

a <- ggplot(RTI_GS_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=myco),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_GS_sub$Gen_Spp) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[15], x=-25, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[15], x=-8, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[21], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[21],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[11], x=-30, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[35], x=-30, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "S-Influenced Growth Rate Effect", shape = "Mycorrhizal Association   ",
       x = expression(Species-Level~Growth~Rate~Effect~(g(S,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

a <- a + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
a

RTI_SS_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, myco, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_S_00:S_S_19), funs(median), na.rm = TRUE)

## Create new names for the variables that are output from the function
oldnames = c("S_S_00", "S_S_01", "S_S_02", "S_S_03",
             "S_S_04", "S_S_05", "S_S_06", "S_S_07",
             "S_S_08", "S_S_09", "S_S_10", "S_S_11",
             "S_S_12", "S_S_13", "S_S_14", "S_S_15",
             "S_S_16", "S_S_17", "S_S_18", "S_S_19")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
RTI_SS_State <- RTI_SS_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_SS_State <- RTI_SS_State %>% mutate_all(na_if,"")
RTI_SS_State$SPCD <- RTI_SS_State$spp_code

RTI_SS_State <- RTI_SS_State %>% 
  drop_na(SPCD, Gen_Spp)

RTI_SS_sub <- subset(RTI_SS_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "myco", "2000", "2019"))

RTI_SS_sub$Gen_Spp <- factor(RTI_SS_sub$Gen_Spp, levels=as.character(RTI_SS_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_SS_sub$p_2000 <- RTI_SS_sub$`2000`*100
RTI_SS_sub$p_2019 <- RTI_SS_sub$`2019`*100

theme_set(theme_classic())

RTI_SS_sub <- RTI_SS_sub %>%
  filter(!is.na(p_2000))

# Create a new variable that combines pheno.type and p_2000
RTI_SS_sub <- RTI_SS_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_SS_sub <- RTI_SS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_SS_sub <- RTI_SS_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_SS_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

b <- ggplot(RTI_SS_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=myco),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_SS_sub$Gen_Spp) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 0.5, linetype="dashed") +
  annotate(geom="text", y=y_order[51], x=-28, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[51], x=-5, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[21], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[21],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[10], x=-20, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[36], x=-20, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "S-Influenced Survival Rate Effect",shape = "Mycorrhizal Association   ",
       x = expression(Species-Level~Survival~Rate~Effect~(s(S,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

b <- b + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
b
#### Nitrogen Dumbbell Plots


RTI_GN_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, myco, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(G_N_00:G_N_19), funs(median), na.rm = TRUE)

## Create new names for the variables that are output from the function
oldnames = c("G_N_00", "G_N_01", "G_N_02", "G_N_03",
             "G_N_04", "G_N_05", "G_N_06", "G_N_07",
             "G_N_08", "G_N_09", "G_N_10", "G_N_11",
             "G_N_12", "G_N_13", "G_N_14", "G_N_15",
             "G_N_16", "G_N_17", "G_N_18", "G_N_19")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
RTI_GN_State <- RTI_GN_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_GN_State <- RTI_GN_State %>% mutate_all(na_if,"")
RTI_GN_State$SPCD <- RTI_GN_State$spp_code

RTI_GN_State <- RTI_GN_State %>% 
  drop_na(SPCD, Gen_Spp)

RTI_GN_sub <- subset(RTI_GN_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "myco", "2000", "2019"))

RTI_GN_sub$Gen_Spp <- factor(RTI_GN_sub$Gen_Spp, levels=as.character(RTI_GN_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_GN_sub$p_2000 <- RTI_GN_sub$`2000`*100
RTI_GN_sub$p_2019 <- RTI_GN_sub$`2019`*100

RTI_GN_sub <- RTI_GN_sub %>%
  filter(!is.na(p_2000))

theme_set(theme_classic())

# Create a new variable that combines pheno.type and p_2000
RTI_GN_sub <- RTI_GN_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_GN_sub <- RTI_GN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_GN_sub <- RTI_GN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_GN_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

c <- ggplot(RTI_GN_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=myco),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_GN_sub$Gen_Spp) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[32], x=110, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[32], x=25, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[25], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[25],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[12], x=120, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[40], x=120, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "N-Influenced Growth Rate Effect", shape = "Mycorrhizal Association   ",
       x = expression(Species-Level~Growth~Rate~Effect~(g(N,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

c <- c + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
c

RTI_SN_State <- RTI_States %>%
  group_by(spp_code, Gen_Spp, family, myco, pheno.type) %>%
  filter_at(vars(ends_with("Domain")), all_vars(. == 0)) %>%
  summarize_at(vars(S_N_00:S_N_19), funs(median), na.rm = TRUE)

## Create new names for the variables that are output from the function
oldnames = c("S_N_00", "S_N_01", "S_N_02", "S_N_03",
             "S_N_04", "S_N_05", "S_N_06", "S_N_07",
             "S_N_08", "S_N_09", "S_N_10", "S_N_11",
             "S_N_12", "S_N_13", "S_N_14", "S_N_15",
             "S_N_16", "S_N_17", "S_N_18", "S_N_19")
newnames = c("2000", "2001", "2002", "2003", "2004", "2005", "2006",
             "2007", "2008", "2009", "2010", "2011", "2012", "2013",
             "2014","2015", "2016", "2017", "2018", "2019")

## Rename the variables 
RTI_SN_State <- RTI_SN_State %>% 
  rename_at(vars(oldnames), ~ newnames)

RTI_SN_State <- RTI_SN_State %>% mutate_all(na_if,"")
RTI_SN_State$SPCD <- RTI_SN_State$spp_code

RTI_SN_State <- RTI_SN_State %>% 
  drop_na(Gen_Spp, SPCD)

RTI_SN_sub <- subset(RTI_SN_State, select = c("SPCD", "Gen_Spp", "family", "pheno.type", "myco", "2000", "2019"))

RTI_SN_sub$Gen_Spp <- factor(RTI_SN_sub$Gen_Spp, levels=as.character(RTI_SN_sub$Gen_Spp))  # for right ordering of the dumbells
RTI_SN_sub$p_2000 <- RTI_SN_sub$`2000`*100
RTI_SN_sub$p_2019 <- RTI_SN_sub$`2019`*100

RTI_SN_sub <- RTI_SN_sub %>%
  filter(!is.na(p_2000))

theme_set(theme_classic())

# Create a new variable that combines pheno.type and p_2000
RTI_SN_sub <- RTI_SN_sub %>%
  mutate(group = paste0(pheno.type, "-", p_2000)) 

# Create a new ordering variable
RTI_SN_sub <- RTI_SN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create a new ordering variable
RTI_SN_sub <- RTI_SN_sub %>%
  mutate(ordering_var = as.numeric(ifelse(pheno.type == "E", 1000000 - p_2000, 2000000 - p_2000))) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup()

# Create the custom ordering for y-axis
y_order <- RTI_SN_sub %>%
  group_by(group) %>%
  arrange(ordering_var) %>%
  mutate(new_ordering_var = seq_along(ordering_var)) %>%
  ungroup() %>%
  mutate(y = paste0(group, "_", new_ordering_var)) %>%
  pull(y)

d <- ggplot(RTI_SN_sub, aes(x=p_2000, xend=p_2019, y = new_ordering_var,
                            group=interaction(pheno.type, Gen_Spp))) + 
  geom_dumbbell(aes(shape=myco),size=1, color="#e3e2e1",
                dot_guide = TRUE, dot_guide_colour = "#e3e2e1", dot_guide_size = 1,
                size_x = 3.2,
                size_xend = 3.2,
                colour_x = "olivedrab", 
                colour_xend = "dodgerblue") + 
  scale_y_discrete(limits = y_order, labels = RTI_SN_sub$Gen_Spp) +
  geom_vline(aes(xintercept = 0), 
             colour = "red", alpha = 1, linetype="dashed") +
  annotate(geom="text", y=y_order[15], x=60, label="2000", size = 5,
           color="olivedrab", fontface = 2) +
  annotate(geom="text", y=y_order[15], x=30, label="2019", size = 5,
           color="dodgerblue", fontface = 2) + 
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = y_order[14], ymax = Inf,
           fill = "cadetblue4", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom = "rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = y_order[14],
           fill = "darkseagreen", alpha = 0.3, inherit.aes = FALSE) +
  annotate(geom="text", y=y_order[7], x=40, label="Evergreen", size = 4,
           color="black", fontface = 2) + 
  annotate(geom="text", y=y_order[28], x=40, label="Deciduous", size = 4,
           color="black", fontface = 2) + 
  labs(title  = "N-Influenced Survival Rate Effect",shape = "Mycorrhizal Association    ",
       x = expression(Species-Level~Survival~Effect~(s(N,Q5)))) +
  theme(text = element_text(size = 11.5), 
        axis.text.x = element_text(angle = 45, hjust = 1, size = 11.5, colour = "black"),
        axis.text.y = element_text(hjust = 1, size = 11.5, colour = "black", face = "italic"),
        axis.title.y=element_blank(),
        legend.text = element_text(size = 14, face = "bold"),
        aspect.ratio=2.5,
        panel.grid.minor.x=element_blank(),
        panel.grid.major.x=element_blank(),
        axis.ticks=element_line(),
        plot.title = element_text(size = 14, face = "bold"),
        legend.position="bottom",
        panel.border=element_blank(),
        panel.background = element_rect(fill = "transparent", colour = NA)) 

d <- d + guides(shape = guide_legend(override.aes = list(size = 5, color="black")))
d
figure <- ggarrange(c, a, d, b, labels = c("a", "c", "b", "d"), 
                    hjust = -6, vjust = 1.2, common.legend = TRUE,
                    legend = "bottom",# Second row with box and dot plots
                    nrow = 2, ncol = 2) 

png("Species Median Dumbbell.png", height = 1400, width = 900)

figure

dev.off()
