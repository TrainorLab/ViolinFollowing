prep <- function(following) {
  
  # Make Trial and Participant factors
  following$Trial <- factor(following$Trial <- factor(following$Trial, ordered = TRUE))
  following$Participant <- factor(following$Participant, ordered = TRUE)
  
  # RESHAPE
  # Reshape data for comparison across conditions. This puts all the GC values into ONE column,
  # and makes another for condition (GC_r2p or GC_p2r)
  ## "Direction" can now be treated as a between-subjects factor with two levels
  
  long_following <- following
  long_following <- subset(long_following, select = -CC) # take off CC column
  long_following <- melt(long_following, stringsAsFactors = FALSE)
  long_following$variable <- factor(long_following$variable, ordered = FALSE)
  long_following$variable <- revalue(long_following$variable,
                                        c("GC_r2p"="Recording to Performance", "GC_p2r"="Performance to Recording"))
  colnames(long_following)[colnames(long_following) %in%
                                c("variable", "value")] <- c("Direction", "GC")
  
  return(list(following,long_following))
}
