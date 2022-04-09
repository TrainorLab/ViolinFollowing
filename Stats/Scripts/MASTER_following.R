# Following study prep script
# L. Klein - March 2022


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## PREP AND LOAD
# necessary
library(readr) # for reading in csv files
library(dplyr); library(plyr)
library(reshape)
library(ggplot2)
library(ggpubr) # for arranging plots
library(lme4)


# possibly not necessary?
# library(lsr)
# library(Rmisc)
# library(psych)
# library(magrittr)

setwd('/Users/lucas/Desktop/Following/ANALYSIS/3R')
imageDirectory <- "/Users/lucas/Desktop/Following/ANALYSIS/3R/Images/"
source('Scripts/prep.R')

# ~~~ CHANGE THESE ~~~
piece <- "Danny Boy" # Which piece are we analyzing?
section <- "whole" # Which section? Leave blank for whole piece


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## READ IN DATA
filename <- paste("following_",piece,"_",section,".csv",sep='')
following <- read.csv(filename, header = TRUE, na.strings = c("","NA")) # E.g. "following_Danny Boy_22_1.csv"
#ccorr <- read.csv("ccorr.csv", header = TRUE, na.strings = c("", "NA"))
summary(following)
head(following)
#str(following) # make sure all columns are the correct data type
print(colSums(is.na(following))) # Are there any NAs?


## PREP
data <- prep(following) # list of 2 items: data in two formats
following <- data[[1]] # wide format, with CC values
long_following <- data[[2]] # long format, without CC values
num_participants <- length(unique(following$Participant)) # 8


## STATS
summary(following)
# T-test between directions
t.test(following$GC_r2p,following$GC_p2r,paired = T,alternative = "two.sided")

# 






## SAVE DATA - CHAANGE VARIABLE NAME HERE (following2.rda)
save(following, file=paste("following_",piece,"_",section,".rda",sep=''))
save(long_following, file = paste("long_following_",piece,"_",section,".rda",sep=''))

