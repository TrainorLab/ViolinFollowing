# Following study plotting
# L. Klein - August 2020
# Edited January 2022

library(plyr); library(dplyr)
library(tidyverse) # for general coding + includes ggplot2 which we need for graphing
library(reshape2)
library(readr) # for reading in csv files
library(plyr); library(dplyr)
library(ggplot2)
library(ggpubr)
library(ggthemes)
library(cowplot) # another fun add-on to ggplot
library(gridExtra) # for arranging plots together
library(ez)
library(TOSTER)
library(wesanderson)

setwd('/Users/lucas/Desktop/Following/ANALYSIS/3R/')
imageDirectory <- "/Users/lucas/Desktop/Following/ANALYSIS/3R/Images/"



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~ CHANGE THESE ~~~
piece <- "In The Garden" # Which piece are we analyzing?
section <- "whole" # Which section? Leave blank for whole piece

## LOAD DATA
load(paste("following_",piece,"_",section,".rda",sep = ''))
load(paste("reshape_following_",piece,"_",section,".rda",sep = ''))

rf_filt <- reshape_following
f_filt <- following


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# SEPARATING BY PLAYING EXPERIENCE
if(piece == "Danny Boy") {
  folkplayers <- filter(rf_filt, Participant %in% c(4,5,8))
  nonfolkplayers <- filter(rf_filt, Participant %in% c(1,2,3,6,7))
  earplayers <- filter(rf_filt, Participant %in% c(2,3,4,5,8))
  nonearplayers <- filter(rf_filt, Participant %in% c(1,6,7))
} else {
  folkplayers <- filter(rf_filt, Participant %in% c(3,4,5,6))
  nonfolkplayers <- filter(rf_filt, Participant %in% c(1,2,7,8))
  earplayers <- filter(rf_filt, Participant %in% c(1,2,3,4,5,6))
  nonearplayers <- filter(rf_filt, Participant %in% c(7,8))
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Title for whole piece
if(piece == "Danny Boy" && section == "whole") {
  plot_title <- "Piece 1: Danny Boy"
} else {
  plot_title <- "Piece 2: In The Garden"
}

# Title for sections
# Auto
plot_title <- paste(piece," - ","section ",section,sep = '')
plot_title <- paste("Section ",section,sep = '')
# Manual
plot_title <- "In The Garden - 'by ear' players"

## GC BY TRIAL
plotting <- earplayers # what do you want to plot?

gc_trial_filt <- ggplot(plotting, aes(Trial, GC, color = Direction)) +
  geom_smooth(method='lm', se=FALSE, col='red', size=2) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  stat_summary(fun = mean, geom = "line", aes(group = Direction), size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  scale_color_manual(values=c('darkorchid4','springgreen4')) +
  labs(x = "Trial", y = "GC value", color = "Direction") +
  ggtitle(plot_title) +
  theme_bw() +
  scale_fill_brewer("Group", palette = "Dark2") +
  #scale_y_continuous(limits = c(0.00, 0.2)) +
  coord_cartesian(ylim = c(0, 0.11)) +
  theme(panel.grid.major.x = element_line(),
        panel.grid.major.y = element_line(),
        plot.title = element_text(size=18, vjust=.5, hjust = .5),
        legend.title = element_text(size=12, hjust = .5),
        legend.key.size = unit(0.5, "cm"),
        legend.text = element_text(size=8),
        legend.background = element_rect(color = "black"),
        axis.title = element_text(size=12),
        axis.title.y = element_text(vjust=1),
        axis.title.x = element_text(vjust=1),
        axis.text = element_text(size=10, colour="black"))
gc_trial_filt

# Auto
ggsave(paste(imageDirectory,piece,"_",section,".png",sep=''), plot=gc_trial_filt, width = 7, height = 5)

# Manual
ggsave(paste(imageDirectory,piece,"_",section,"_ear.png",sep=''), plot=gc_trial_filt, width = 7, height = 5)

# For saving sections separately
section15_2 <- gc_trial_filt
section22_1 <- gc_trial_filt
section22_2 <- gc_trial_filt
section22_3 <- gc_trial_filt

sections_all <- ggarrange(section15_2, section22_1, section22_2, section22_3) +
  theme(legend.position = "none")
ggsave(paste(imageDirectory,"following_",piece,"_allsections.png",sep=''),sections_all)
#labels = c("15 seconds","22 seconds (1)","22 seconds (2)","22 seconds (3)"),
#ncol = 2, nrow = 2)
#theme(legend.position = "none")

#figure <- ggarrange(gc_trial_r2p, gc_trial_p2r,
#                    labels = c("A", "B", "C"),
#                    ncol = 2, nrow = 2)
#figure


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ALL DS RATES, BOTH DIRECTIONS:
gc_trial <- ggplot(data = following, aes(x = Trial, y = GC_r2p, color = Downsample)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Downsample),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "GC value") +
  ggtitle("Granger causality:\nPerformance to Recording") +
  theme_bw() +
  scale_color_brewer(format("Downsampling freq. (Hz)", justify = "right"), palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.13)) +
  theme(panel.grid.major.x = element_line(),
        panel.grid.major.y = element_line(),
        plot.title = element_text(size=21, vjust=1),
        axis.title = element_text(size=14),
        legend.title = element_text(size=14),
        legend.key.size = unit(0.5, "cm"),
        legend.text = element_text(size=12),
        legend.background = element_rect(color = "black"),
        axis.title.y = element_text(vjust=1),
        axis.title.x = element_text(vjust=1),
        axis.text = element_text(size=14, colour="black")) +
  theme(plot.title = element_text(hjust = 0.5))
gc_trial


# ALL DS RATES, RECORDING TO PERFORMANCE
gc_trial_r2p <- ggplot(data = following, aes(x = Trial, y = GC_r2p, color = Downsample)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Downsample),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "GC value") +
  ggtitle("Granger causality:\nRecording to Performance") +
  theme_bw() +
  scale_color_brewer(format("Downsampling freq. (Hz)", justify = "right"), palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.13)) +
  theme(panel.grid.major.x = element_line(),
        panel.grid.major.y = element_line(),
        plot.title = element_text(size=21, vjust=1),
        axis.title = element_text(size=14),
        legend.title = element_text(size=14),
        legend.key.size = unit(0.5, "cm"),
        legend.text = element_text(size=12),
        legend.background = element_rect(color = "black"),
        axis.title.y = element_text(vjust=1),
        axis.title.x = element_text(vjust=1),
        axis.text = element_text(size=14, colour="black")) +
  theme(plot.title = element_text(hjust = 0.5))
gc_trial_r2p
gc_trial_r2p + gc_trial_p2r


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### PLOT CC VALUES
# Plot CC values for both pieces
ccorr_both <- ggplot(data = ccorr_filt, aes(x = Trial, y = CC, color = Piece)) +
  stat_summary(fun = mean, geom = "point", size = 2) +
  stat_summary(fun = mean, geom = "line", aes(group = Piece),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "CC value") +
  ggtitle("Cross-Correlation") +
  theme_bw() +
  scale_color_brewer(format("Piece", justify = "none"), palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.5)) +
  theme(panel.grid.major.x = element_line(),
        panel.grid.major.y = element_line(),
        plot.title = element_text(size=21, vjust=1),
        axis.title = element_text(size=14),
        legend.title = element_text(size=14),
        legend.key.size = unit(0.5, "cm"),
        legend.text = element_text(size=12),
        legend.background = element_rect(color = "black"),
        axis.title.y = element_text(vjust=1),
        axis.title.x = element_text(vjust=1),
        axis.text = element_text(size=14, colour="black")) +
  theme(plot.title = element_text(hjust = 0.5))

ccorr_both

#2 - CC by trial (all down-sampling rates)
cc_trial_filt <- ggplot(data = following, aes(x = Trial, y = CC, color = Downsample)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Downsample),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "CC value") +
  ggtitle("Cross-Correlation") +
  theme_bw() +
  scale_color_brewer(format("Downsampling\nfreq (Hz).", justify = "right"), palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.5)) +
  theme(panel.grid.major.x = element_line(),
        panel.grid.major.y = element_line(),
        plot.title = element_text(size=21, vjust=1),
        axis.title = element_text(size=14),
        legend.title = element_text(size=14),
        legend.key.size = unit(0.5, "cm"),
        legend.text = element_text(size=12),
        legend.background = element_rect(color = "black"),
        axis.title.y = element_text(vjust=1),
        axis.title.x = element_text(vjust=1),
        axis.text = element_text(size=14, colour="black")) +
  theme(plot.title = element_text(hjust = 0.5))
cc_trial_filt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# BOXPLOTS - using reshape_following
# Boxplot of GC values in both directions (without CC)
boxplot(GC ~ Trial, data = subset(rf_filt, Direction != 'CC'))
stripchart(rf_filt$GC ~ rf_filt$Direction, vertical=TRUE,
           method = "jitter", pch=19, add=TRUE, col=1:length(levels(rf_filt)))

gc_direction <- ggplot(data=rf_filt, aes(x=Direction, y=GC)) +
  geom_violin() +
  labs(x = "Direction", y = "GC value") +
  ggtitle("Granger causality @ 8 Hz") +
  theme_bw() +
  scale_color_brewer(palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.13)) +
  theme(panel.grid.major.x = element_line(),
        panel.grid.major.y = element_line(),
        plot.title = element_text(size=21, vjust=1),
        axis.title = element_text(size=14),
        legend.title = element_text(size=14),
        legend.key.size = unit(0.5, "cm"),
        legend.text = element_text(size=12),
        legend.background = element_rect(color = "black"),
        axis.title.y = element_text(vjust=1),
        axis.title.x = element_text(vjust=1),
        axis.text = element_text(size=14, colour="black")) +
  theme(plot.title = element_text(hjust = 0.5))
gc_direction

geom_jitter(shape=16, position=position_jitter(0.2))



gc_trial_all <- ggplot(data = rf_filt, aes(x = Trial, y = GC)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Direction),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2)
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
gc_trial_all
  


# Visualize
avgdat0 <- following %>%
  summarise(
    MeanCC = mean(CC, na.rm = T),
    SD = sd(CC, na.rm = T),
    MedCC = median(CC, na.rm = T),
    MinRng = min(CC),
    MaxRng = max(CC),
    N = n()
  )
head(avgdat0)

# Effect of trial by direction
triall <- ggplot(data = following, aes(x = Trial, y = GC_r2p)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_grid(. ~ CC, margins = T)


# Scatter plot
#sp+scale_color_manual(values=wes_palette(n=3, name="GrandBudapest"))


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## BAR PLOTS
bar_plot <- following_gc %>%
  ggplot(aes(x = Trial,
             y = GC_r2p,
             fill = Participant)) +
  stat_summary(fun = mean, # this  function will output the mean values of your y variable
               geom = "bar", # rather than adding a separate geom, we can just place it within stat_summary
               width = 0.69, # width individual bars
               position = position_dodge(width = .9)) # (smaller # = bars closer together)
bar_plot

bar_plot + stat_summary(fun.data = mean_se, # this function will be applied to all of the data
                        geom = "errorbar",
                        width = 0.09, # width of "ticks"
                        position = position_dodge(width = 0.9)) + # needs to match width of bars (so they're aligned)
  facet_wrap(Participant) + # split figure by participant
  scale_fill_manual("Group", values = c("darkgreen", "darkolivegreen3")) + 
  scale_fill_brewer("Group", palette = "Accent") + # change the colour
  labs(title = "Granger Causality: Recording --> Performance", # add an overall title
       x = "Trial", # x-axis title
       y = "GC value") + # y-axis title
  theme(legend.position = "bottom") # legend position



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## FILTER DATA for one downsampling rate
# (don't need to do this anymore because we're only using one ds rate)
# ds_rates <- unique(following$Downsample)
# ds_rate <- 8 # set which downsampling rate we want to analyze
f_filt <- filter(following, Downsample == ds_rate)
rf_filt <- filter(reshape_following, Downsample == ds_rate)
head(f_filt)
head(rf_filt)



