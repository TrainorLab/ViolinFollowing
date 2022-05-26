plots_following <- function(x) {
  library(grid)
  library(wesanderson)
  library(plyr)
  library(dplyr)
  
  plots <- {}
  thm <- theme(panel.grid.major.x = element_line(),
               panel.grid.major.y = element_line(),
               plot.title = element_text(size=18, vjust=.5, hjust = .5),
               legend.title = element_text(size=14, hjust = .5),
               legend.key.size = unit(0.5, "cm"),
               legend.text = element_text(size=10),
               legend.background = element_rect(color = "black"),
               legend.position = "bottom",
               axis.title = element_text(size=14),
               axis.title.y = element_text(vjust=1),
               axis.title.x = element_text(vjust=1),
               axis.text = element_text(size=10, colour="black"))

  for (g in 1:2){ # Do plotting (and save) for each piece separately
    
    if (g == 1){
      title <- "Piece 1: Danny Boy"}
    else{
      title <- "Piece 2: In the Garden"}

    # ~~~~~
    
    p <- x[[g]] # GC data from piece 1 and then piece 2
    gc <- ggplot(data=p, aes(Trial, GC, color = Direction)) +
      #geom_smooth(method='lm', se=FALSE, col='red', size=2) +
      stat_summary(fun = mean, geom = "point", size = 2) +
      stat_summary(fun = mean, geom = "line", aes(group = Direction), size=1) +
      stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
      labs(x = "Trial", y = "Granger causality", color = "Direction") +
      ggtitle(title) +
      theme_bw() +
      scale_color_manual(values=c('darkorchid4','springgreen4')) +
      scale_fill_brewer("Group", palette = "Dark2") +
      #scale_y_continuous(limits = c(0.00, 0.2)) +
      coord_cartesian(ylim = c(0, 0.11)) +
      thm
    
    gc_parts <- gc + facet_wrap(vars(Participant))
    
    p_sub <- p[p$Trial %in% c(1,8),] # define subset of data: only trials 1 & 8
    vi <- ggplot(data=p, aes(x=Direction, y=GC)) +
      geom_violin(aes(fill=Direction)) + 
      geom_point(aes(group=Trial)) +
      geom_line(data=p_sub, aes(group=interaction(Trial, Participant), color=Trial), alpha=.7) +
      scale_color_manual(values = c("black", "gray"), labels=c("Trial 1", "Trial 8")) +
      labs(y = "Granger causality") +
      ggtitle(title) +
      theme_bw() +
      scale_fill_manual(values=c('darkorchid4','springgreen4')) +
      #scale_color_brewer(palette = "Dark2") +
      thm +
      theme(axis.text.x=element_blank(),
            legend.title = element_blank())
            
    
    # ~~~~~
  
    q <- x[[g+2]] # CC data from piece 1 and then piece 2
    cc <- ggplot(q, aes(x=Trial, y=CC, Group=1)) +
      #geom_smooth(method='lm', se=FALSE, col='red', size=2) +
      stat_summary(fun = mean, geom = "point", color="blue", size=2) +
      stat_summary(fun = mean, geom = "line", aes(group=1), color="blue", size=1) +
      stat_summary(fun.data = mean_se, geom = "errorbar", color="blue", width = 0.2) +
      labs(x = "Trial", y = "Cross-correlation") +
      ggtitle(title) +
      theme_bw() +
      #scale_color_manual(values=c('darkorchid4','springgreen4')) +
      #scale_colour_manual(wes_palette("Darjeeling1",43,type=("continuous"))) +
      #scale_fill_brewer("Group", palette = "Dark2") +
      #scale_y_continuous(limits = c(0.00, 0.2)) +
      #coord_cartesian(ylim = c(0, 0.11)) +
      thm
    
    cc_parts <- cc + facet_wrap(vars(Participant))
    
    plots[[g]] <- gc
    plots[[g+2]] <- cc
    plots[[g+6]] <- vi
    plots[[g+8]] <- gc_parts
    plots[[g+10]] <- cc_parts
    
  } # (end of for loop)
  
  # ~~~~~ Pieces combined
  
  r <- x[[5]] # GC values for both pieces
  gcs <- ggplot(data=r, aes(Trial, GC, color = Direction)) +
    #geom_smooth(method='lm', se=FALSE, col='red', size=2) +
    stat_summary(fun = mean, geom = "point", size = 2) +
    stat_summary(fun = mean, geom = "line", aes(group = Direction), size=1) +
    stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
    labs(x = "Trial", y = "Granger causality", color = "Direction") +
    ggtitle("Piece") +
    theme_bw() +
    scale_color_manual(values=c('darkorchid4','springgreen4')) +
    scale_fill_brewer("Group", palette = "Dark2") +
    #scale_y_continuous(limits = c(0.00, 0.2)) +
    coord_cartesian(ylim = c(0, 0.11)) +
    thm
  
  s <- x[[6]] # CC values for both pieces
  ccs <- ggplot(s, aes(x=Trial, y=CC, Group=1)) +
    #geom_smooth(method='lm', se=FALSE, col='red', size=2) +
    stat_summary(fun = mean, geom = "point", color="blue", size=2) +
    stat_summary(fun = mean, geom = "line", aes(group=1), color="blue", size=1) +
    stat_summary(fun.data = mean_se, geom = "errorbar", color="blue", width = 0.2) +
    labs(x = "Trial", y = "Cross-correlation") +
    #ggtitle(Piece) +
    theme_bw() +
    #scale_color_manual(values=c('darkorchid4','springgreen4')) +
    #scale_colour_manual(wes_palette("Darjeeling1",43,type=("continuous"))) +
    #scale_fill_brewer("Group", palette = "Dark2") +
    #scale_y_continuous(limits = c(0.00, 0.2)) +
    #coord_cartesian(ylim = c(0, 0.11)) +
    thm
  
  plots[[5]] <- gcs
  plots[[6]] <- ccs

  return(plots)
}



