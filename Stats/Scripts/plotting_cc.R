# Following study plotting
# L. Klein - August 2020

load("following_cc.rda")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#PLOTTING
# Visualize
ggplot(data = following_cc, aes(x = CCvals)) +
  geom_density()

avgdat0 <- following_cc %>%
  summarise(
    MeanCC = mean(CCvals, na.rm = T),
    SD = sd(CCvals, na.rm = T),
    MedCC = median(CCvals, na.rm = T),
    MinRng = min(CCvals),
    MaxRng = max(CCvals),
    N = n()
  )
head(avgdat0)

# Effect of trial by direction
# Let's plot the effect of frequency by gender
ggplot(data = following_cc, aes(x = Trial, y = CCvals)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_grid(. ~ CCvals, margins = T)


# Scatter plot
#sp+scale_color_manual(values=wes_palette(n=3, name="GrandBudapest"))



#three ways of plotting

#1 - Collapsing across participant
cc_participant_collapsed <- ggplot(data = following_cc, aes(x = Trial, y = CCvals, color = DownsampleL)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Downsample),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "CC value") +
  ggtitle("Cross-Correlation") +
  theme_bw() +
  scale_color_brewer(format("Downsampling\nfreq.", justify = "right"), palette = "Dark2") +
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

cc_participant_collapsed



# ~~~~~
#2 - Same as above, for each participant separately, at a specific downsampling rate
cc_collapsed_8Hz <- ggplot(subset(following_cc, Downsample %in% c("8")), aes(x = Trial, y = CCvals, color = Participant)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Participant),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "CC value") +
  ggtitle("Cross-Correlation") +
  theme_bw() +
  scale_color_brewer(format("Downsampling freq. -\nSuggested model order", justify = "right"), palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.9)) +
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

cc_collapsed_7Hz




# ~~~~~
#2 - Same as above, for each participant separately, at a specific downsampling rate
cc_collapsed_8Hz <- ggplot(subset(following_cc, Downsample %in% c("8")), aes(x = Trial, y = CCvals, color = Participant)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", aes(group = Participant),size=1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  #scale_color_manual(values=c('firebrick4', 'goldenrod1')) +
  labs(x = "Trial", y = "CC value") +
  ggtitle("Cross-Correlation") +
  theme_bw() +
  scale_color_brewer(format("Downsampling freq. -\nSuggested model order", justify = "right"), palette = "Dark2") +
  scale_y_continuous(limits = c(0.00, 0.9)) +
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

cc_collapsed_7Hz

########################
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






