lmer_following <- function(x) {

  M <- list()
  
  # ~~~~~ GC ~~~~~
  if ("GC" %in% colnames(x)){
    
    # FIXED: trial, RANDOM: participant
    #M[[1]] <- lmer(GC ~ 1 + (1|Trial), data=x, REML=0) # reduced
    M[[1]] <- lmer(GC ~ 1 + (1|Participant), data=x, REML=0)
    #M[[1]] <- lmer(GC ~ 1 + (1|Participant), data=x, control = lmerControl(optimizer = "bobyqa"))
    M[[2]] <- lmer(GC ~ 1 + Trial + (1|Participant), data=x, REML=0)
    #M[[2]] <- lmer(GC ~ 1 + Trial + (1|Participant), data=x, control = lmerControl(optimizer = "bobyqa"))
    
    
    if (length(unique(x$Piece))==2) { # for combined pieces
      # FIXED: trial, RANDOM: participant
      M[[3]] <- lmer(GC ~ 1 + Trial + (1|Participant), data=x, REML=0)
      # FIXED: trial, direction, RANDOM: piece
      M[[4]] <- lmer(GC ~ 1 + Trial + (1|Piece), data=x, REML=0)
      M[[5]] <- lmer(GC ~ 1 + Trial + (1|Piece) + (1|Participant), data=x, REML=0)
      M[[6]] <- lmer(GC ~ 1 + Trial + Trial*Piece + (1|Piece) + (1|Participant), data=x, REML=0)
      # FIXED: trial + piece interaction, RANDOM: Participant
      M[[7]] <- lmer(GC ~ 1 + Trial*Participant + (1|Piece), data=x, REML=0)
      
      # REDUCED
      M[[8]] <- lmer(GC ~ 1 + (1|Participant) + (1|Piece), data=x, REML=0)
    }
    
    
  # ~~~~ CC ~~~~~  
  } else {
    M[[1]] <- lmer(CC ~ 1 + (1|Participant), data=x, REML=0) # REDUCED
    M[[2]] <- lmer(CC ~ 1 + Trial + (1|Participant), data=x, REML=0)
    M[[9]] <- lmer(CC0 ~ 1 + (1|Participant), data=x, REML=0) # REDUCED
    M[[10]] <- lmer(CC0 ~ 1 + Trial + (1|Participant), data=x, REML=0)
    M[[11]] <- lmer(CC_l ~ 1 + (1|Participant), data=x, REML=0) # REDUCED
    M[[12]] <- lmer(CC_l ~ 1 + Trial + (1|Participant), data=x, REML=0)
    
    if (length(unique(x$Piece))==2) { # for combined pieces
      M[[3]] <- lmer(CC ~ 1 + Trial + (1|Participant), data=x, REML=0) # same again, but with all data
      M[[4]] <- lmer(CC ~ 1 + Trial + (1|Piece), data=x, REML=0)
      M[[5]] <- lmer(CC ~ 1 + Trial + (1|Participant) + (1|Piece), data=x, REML=0)

      M[[6]] <- lmer(CC ~ 1 + Trial*Piece + (1|Participant), data=x, REML=0)
      # FIXED: trial + piece interaction, RANDOM: Participant
      M[[7]] <- lmer(CC ~ 1 + Trial*Participant + (1|Piece), data=x, REML=0)
      
      # REDUCED
      M[[8]] <- lmer(CC ~ 1 + (1|Participant) + (1|Piece), data=x, REML=0)
      
      #M[[8]] <- lmer(CC ~ 1 + Trial + Piece + Trial*Piece + (1|Participant), data=x, REML=0)
    }
  }
  
  return(M)
}
