prep_following <- function(following1, following2) {
  
  # Make Trial and Participant factors - important for reshaping
  following1$Trial <- factor(following1$Trial, ordered = TRUE)
  following1$Participant <- factor(following1$Participant, ordered = FALSE)
  following1$Piece <- factor(following1$Piece, ordered = FALSE)
  
  # RESHAPE
  # Reshape data for comparison across conditions. This puts all the GC values into ONE column,
  # and makes another for condition (GC_r2p or GC_p2r)
  ## "Direction" can now be treated as a between-subjects factor with two levels
  
  lf1 <- subset(following1, select = -c(CC,CC0)) # take off CC column
  lf1 <- melt(lf1, stringsAsFactors = FALSE)
  lf1$variable <- factor(lf1$variable, ordered = FALSE)
  
  # Re-value direction labels
  lf1$variable <- revalue(lf1$variable, c("GC_r2p"="Recording to Performance", "GC_p2r"="Performance to Recording"))
  #lf1$variable <- revalue(lf1$variable, c("GC_r2p"=1, "GC_p2r"=2))
  
  colnames(lf1)[colnames(lf1) %in% 
                  c("variable", "value")] <- c("Direction", "GC")
  
  cc1 <- subset(following1, select = -c(GC_r2p,GC_p2r)) # take off GC columns
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~
  
  # Make Trial and Participant factors - important for reshaping
  following2$Trial <- factor(following2$Trial, ordered = TRUE)
  following2$Participant <- factor(following2$Participant, ordered = FALSE)
  following2$Piece <- factor(following2$Piece, ordered = FALSE)
  
  lf2 <- subset(following2, select = -c(CC,CC0)) # take off CC column
  lf2 <- melt(lf2, stringsAsFactors = FALSE)
  lf2$variable <- factor(lf2$variable, ordered = FALSE)
  
  # Re-value direction labels
  lf2$variable <- revalue(lf2$variable,c("GC_r2p"="Recording to Performance", "GC_p2r"="Performance to Recording"))
  #lf2$variable <- revalue(lf2$variable,c("GC_r2p"=1, "GC_p2r"=2))
  colnames(lf2)[colnames(lf2) %in%
                  c("variable", "value")] <- c("Direction", "GC")
  
  cc2 <- subset(following2, select = -c(GC_r2p,GC_p2r)) # take off GC columns
  
  # ~~~~~~~~~

  lf_comb <- rbind(lf1, lf2)
  cc_comb <- rbind(cc1, cc2)
  df <- list(lf1, lf2, cc1, cc2, lf_comb, cc_comb)
  
  # ~~~~~~~~~
  
  return(df)
}
