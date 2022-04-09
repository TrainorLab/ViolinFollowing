# Following study analysis
# L. Klein - August 2020
# Last updated: Jan. 2021


# LOAD DATA (from the previously created .rda file)
load(paste("following_",piece,"_",section,".rda",sep=''))
load(paste("reshape_following_",piece,"_",section,".rda",sep=''))


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### STATS

#class(f_filt$Participant)

# Descriptives
avgdat1 <- tapply(rf_filt$GC, rf_filt$Direction, summary)
avgdat1

# Calculate standard error of these means:
avgdat2 <- avgdat1 %>%
  group_by(Direction) %>%
  mutate(SE = SD / sqrt(N))
avgdat2


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## T-TESTS
# Look at difference in GC values for different directions

t.test(f_filt$GC_r2p,f_filt$GC_p2r,paired=T,alternative="two.sided")
# Or...
t.test(rf_filt$GC[rf_filt$Direction == "Recording to Performance"],
       rf_filt$GC[rf_filt$Direction == "Performance to Recording"],
       paired=T,alternative="two.sided")
#cohensD(following$GC_r2p[following$Downsample == "8"],following$GC_p2r[following$Downsample == "6"])


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## CORRELATIONS - using following
cor.test(f_filt$GC_p2r,f_filt$GC_r2p, method="pearson", exact=FALSE)
# non-significant
cor.test(f_filt$CC,f_filt$GC_r2p, method="pearson", exact=FALSE)
# non-significant


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# TREND ANALYSIS - calculation of linear contrasts (comparisons) among levels of a quantitative factor

# Set global options
options(contrasts = c("contr.sum","contr.poly"))
options(digits = 8) # formats the output (8 trials?)

# The Omnibus Test:
# Create a new variable called trialInt that has Trial as an integer
f_filt$trialInt <- as.integer(f_filt$Trial, labels = "t", ordered = FALSE) # create a Trial factor
class(f_filt$trialInt)

y.means.gc <- tapply(f_filt$GC_r2p, f_filt$trialInt, mean) # granger
y.means.cc <- tapply(f_filt$CC, f_filt$trialInt, mean) # cross-correlation
x.group <- as.numeric(sort(unique(f_filt$Trial)))

# Correlation between age and the mean (just for fun)
cor(x.group, y.means.gc) # correlation is quite high (-0.878), there is probabaly an association
cor(x.group, y.means.cc) # .45 (not much)
plot(x.group, y.means.gc)
plot(x.group, y.means.cc)

# ------------------------------------

# Now do an ANOVA
f_filt.aov.gc <- aov(GC_r2p ~ Trial, data = folkplayers)
f_filt.aov.cc <- aov(CC ~ Trial, data = f_filt)
summary(f_filt.aov.gc)
summary(f_filt.aov.cc)
# ...or same results done a different way
f_filt.lm <- lm(GC_r2p ~ Trial, data = f_filt)
summary(f_filt.lm)
anova(f_filt.lm)
# Why is this insignificant? The omnibus F-test evaluates whether there are ANY
# differences across groups. So we need to test for specific (linear) trend

TukeyHSD(f_filt.aov.gc)


# -----------------------------

## TREND ANALYSIS: calculating linear contrasts (comparisons) among levels of a quantitative (ordered) factor
# Contrast weights
contr.poly(n = 8, scores = c(1, 2, 3, 4, 5, 6, 7, 8)) # This command automatically sets up orthogonal contrasts
# assumes equal subjects in each group
# These trend contrasts form an orthogonal set
class(f_filt$Trial) # make sure Trial is an ordered factor
unique(f_filt$Trial) # 8 factors

# PERFORM trend analysis using aov
f_filt.aov.gc <- aov(GC_r2p ~ Trial, data = f_filt)
f_filt.aov.cc <- aov(CC ~ Trial, data = f_filt)
summary(f_filt.aov.gc)
summary(f_filt.aov.cc)
# Results as same as before because ANOVA table shows the overall effect of group
## Omnibus F-test doesn't care whether factor is ordered or not
### So we must partition SS-Trial

summary(f_filt.aov.gc, split = list(Trial = list(linear=1, quadratic=2, cubic=3,
                                                quartic=4)))
summary(f_filt.aov.cc, split = list(Trial = list(linear=1, quadratic=2, cubic=3,
                                                 quartic=4)))
# 7 trials groups because 8 - 1 = 7 orthogonal trends
# 1: linear, 2: quadratic, 3: cubic, 4: quartic
# This table shows SS-contrast, F, and p for each linear comparison (first is linear trend)
# Linear trend is sig, so we reject null
# SS-trial = SS-lin + SS-quad + SS-cub + SS-quart
# 1 df for all trend because they're all linear contrasts
# F-omnibus = (F-lin + F-quad + F-cub + F-quart)/4






# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## RM-ANOVA
# -----------------------
# Assumptions: Outliers, normality, sphericity
# r2p and p2r GC values are two levels of the dependent variables (GC) in rf_filt
# # Dependent variable is continuous (GC value)
# ...while independent (trial #) is categorical (also called "within-subjects factor")

# Basic stats
rf_filt %>% 
  group_by(Direction,Trial) %>%
  get_summary_stats(GC, type="mean_sd")
# Visualize
bxp1 <- ggboxplot(rf_filt, x="Trial", y="GC",
                  color="Direction",palette="jco")
bxp1

# ASSUMPTIONS:
# Outliers
rf_filt %>% 
  group_by(Direction,Trial) %>%
  identify_outliers(GC)
# another method for just looking at outliers within each Direction
identify_outliers(f_filt,GC_r2p) # 1 outlier
identify_outliers(f_filt,GC_p2r) # 3 outliers

# Normality
ggqqplot(rf_filt, "GC", ggtheme=theme_minimal()) + # visualize
  facet_grid(Trial ~ Direction, labeller="label_both")
shapiro_test(f_filt$GC_p2r)
rf_filt %>%
  group_by(Direction, Trial) %>%
  shapiro_test(GC)


# Sphericity - Mauchley's test
# Sphericity is only an issue for >2 levels. So when looking ONLY across Direction,
# ...it doesn't matter. It only matters when looking at Trial
f_filt %>% anova_test(GC_r2p ~ Trial)
rf_filt %>% anova_test(GC ~ Direction)

# Descriptive stats
by(rf_filt$GC, rf_filt$Direction, stat.desc)

# Set contrast between two conditions
PartsvsWhole <- c(1, -1)
contrasts(rf_filt$Direction) <- cbind(PartsvsWhole) # contrasts apply to factors only
# ezANOVA
rm.model.01 <- ezANOVA(data=rf_filt, dv=.(GC), wid=.(Participant),
                     within=.(Direction,Trial), detailed=TRUE, type = 2)
rm.model.01

# Using only Trial?
rm.model.02 <- ezANOVA(data=f_filt, dv=.(GC_r2p), wid=.(Participant),
                       within=.(Trial), detailed=TRUE, type = 3)
rm.model.02


# Regular ANOVA:
rm.model.03 <- aov(GC_r2p ~ Trial, data=f_filt) # same as above ANOVA
summary(rm.model.03)

baseline <- lme(GC ~ 1, random=~1|Participant/Trial, data=rf_filt, method="ML")
rm.model.04 <- lme(GC ~ Trial, random=~1|Participant/Trial, data=rf_filt, method="ML") # maximum likelihood
# including the random effect --> tells model "data with same value of Participant
# ...within different levels of Trial are dependent
summary(rm.model.04)
anova(baseline,rm.model.04)

m00 = lmer(GC ~ 1 + (1|Direction), data=rf_filt,REML=0)
m01 = lmer(GC ~ 1 + Trial + (1|Direction), data=rf_filt,REML=0)
m02 = lmer(GC ~ 1 + Trial + (1|Direction), data=rf_filt,REML=0)

anova(m00, m01)

rmanova(f_filt$GC_r2p, f_filt$Trial, f_filt$Participant)

## SS-total = SS-within + SS-res
# Total df = (7 participants) x (3 df each) = 21

## SS-within: variance explained by individual differences in across conditions
# (...SOME of which is due to the manipulation, some due to random fluctuation)
# SS-within: sum of s^2(n-1) for each person --> total SS-within
# n is number of conditions (2)
# df = 2-1 = 1
# Variation in individual scores, summed across all participants

## SS-model: sum of squared error between two conditional means and grand mean
# df-model = k-1 = 2-1 = 1
# Of the variance explained by individual differences across conditions, 
# ...some portion is explained by the manipulation (SS-model)

## SS-residual: amount of variance caused by extraneous factors outside experimental 
# ...control
# df-res = df-total - df-model = 21-1 = 20

## Mean Squares = average sum of squares, SS-model/df-model or SS-res/df-res
# MS-model: average amount of variation explained by model
# MS-res: gauge of the amount of variation explained by extraneous variables

## F-ratio: ratio of variation explained by model / var explained by extraneous factors
# F = MS-model / MS-res
# "Ratio of systematic variation to unsystematic variation"

# SS-between: variance due to differences between participants (hopefully small)
# SS-bet = SS-total - SS-within


# Suby's method
rf_filt.mean <- aggregate(rf_filt$GC,
                          by = list(rf_filt$Participant, rf_filt$Downsample,
                                    rf_filt$Trial, rf_filt$Direction),
                          FUN = 'mean')


colnames(rf_filt.mean) <- c("Participant","Downsample","Trial","Direction","GC")

rf_filt.mean <- rf_filt.mean[order(rf_filt.mean$Participant), ]
head(rf_filt.mean)

GC.aov <- with(rf_filt.mean,
               aov(GC ~ Trial * Direction +
                     Error(Participant / (Trial * Direction)))
)
summary(GC.aov)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## ANOVA
res.aov <- anova_test(
  data = rf_filt, dv = GC, wid = Participant,
  within = c(Trial, Direction))
summary(aov(GC ~ Direction * Trial, data = rf_filt))
# Sig main effect of Direction, but not Trial. No interaction.

# or...

y.mat <- as.matrix(f_filt[,5]) # extract dep. variable, GC_r2p (use 6 for GC_p2r)
Trials <- as.factor(c("1","2","3","4","5","6","7","8"))
following.idata <- data.frame(Trials)
following.mlm.01 <- lm(y.mat ~ Trial, data = f_filt)
following.aov.01 <- Anova(following.mlm.01, idata=following.idata, idesign=~Trials, type="III")
summary(following.aov.01, multivariate=FALSE)

contr.poly(n=8, scores = c(1, 2, 3, 4, 5, 6, 7, 8))
lin.weights <- contr.poly(n=8, scores = c(1, 2, 3, 4, 5, 6, 7, 8))[,1]
quad.weights <- contr.poly(n=8, scores = c(1, 2, 3, 4, 5, 6, 7, 8))[,2]
lin.scores <- y.mat %*% lin.weights
t.test(lin.scores) # One-sample T-test
# Whaaat's doing on here...

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


## LMER
m0_gc = lmer(GC ~ 1 + (1|Direction), data=rf_filt, REML=0)
m1_gc = lmer(GC ~ 1 + Trial + (1|Direction), data=rf_filt, REML=0)
#m2 = lmer(GC ~ 1 + Trial + (1+Trial|Direction), data=rf_filt, REML=0)
anova(m0_gc,m1_gc)

# Cross-correlation
m0_gc = lmer(CC ~ 1 + (1|Direction), data=rf_filt, REML=0)
m1_gc = lmer(GC ~ 1 + Trial + (1|Direction), data=rf_filt, REML=0)
#m2 = lmer(GC ~ 1 + Trial + (1+Trial|Direction), data=rf_filt, REML=0)






# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# FILTER DATA for just one downsampling rate:
# This is no longer necessary because we are only using one downsampling rate now
ds_rates <- unique(following$Downsample)
ds_rate <- 8 # set which downsampling rate we want to analyze
f_filt <- filter(following, Downsample == ds_rate)
rf_filt <- filter(reshape_following, Downsample == ds_rate)
head(f_filt)
head(rf_filt)
f_filt <- following
rf_filt <- reshape_following







