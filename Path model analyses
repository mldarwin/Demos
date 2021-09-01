# ---Dissertation Analysis Script---
#   
# This script performs the following statistical analyses in R:
#   Descriptive statistics
#   Bi-variate correlations
#   Hypothesis 1: Simple linear regression model
#   Hypothesis 2: Mediation path model
#   Hypothesis 3: Moderated mediation path model
#   
# Marielle L. Darwin | August 26 2021 | Last update: Sept 1 2021

# Install packages
install.packages('lavaan')
install.packages('mediation')
install.packages('lme4')
install.packages('pastecs')
install.packages("ppcor")
install.packages("apaTables")
install.packages("psych")
install.packages('tidyverse')

# Load packages
library(lavaan)
library(mediation)
library(lme4)
library(pastecs)
library(ppcor)
library(apaTables)
library(psych)
library(tidyverse)

# Clear workspace
rm(list = ls())

# Set working directory
setwd("C:/Users/darwinm/Documents/Dissertation/R stats/")

# Load data
data <- read.csv("FINALvariables.csv")

# Assign missing variables
data[data == 99] <- NA

##Descriptive statistics table------------------------

values <- cbind(data$LE_TOTAL, data$AGE, data$SCS_TOTAL, data$CESD_TOTAL, 
                data$CESDnoSC, data$HRV)
options(scipen=100)  #Convert from sci notation
options(digits=2)    #2 decimal places
stat.desc(values)    #Display values

# Scatterplot to visualize variables
# plot(data$SCS_TOTAL, data$HRV, main="Scatterplot Example",
#      +      xlab="SCS_TOTAL ", ylab="HRV")

##Bi-variate correlations -----------------------------

# Correlation matrix accounting for missing data
corFiml(data, covar = FALSE,show=FALSE)

# Output as table with M, SD, correlation value, and significance
apa.cor.table(data, show.conf.interval = TRUE) 

##Hypothesis 1 ----------------------------------------
  # X = HRV
  # Y = SCS_TOTAL

fit <- sem('SCS_TOTAL ~ HRV', data = data,
              missing = 'fiml', fixed.x = F,
              se = "bootstrap",
              bootstrap = 1000)

# Display model output
summary(fit, standardized=TRUE, fit.measures = TRUE)
parameterestimates(fit,
  boot.ci.type = "bca.simple",
  level = .95, ci = TRUE,
  standardized = TRUE)

##Hypothesis 2 ----------------------------------------
  # X = HRV
  # M = SCS_TOTAL
  # Y = CESD_TOTAL

set.seed(050692)
X <- data$HRV
M <- data$SCS_TOTAL
Y <- data$CESD_TOTAL

# Mediation model
mediation.model <- data.frame(X = X, Y = Y, M = M)
model <- ' Y ~ c*X              # Direct effect
           M ~ a*X              # Mediator
           Y ~ b*M
           ab := a*b            # Indirect effect (a*b)
           total := c + (a*b)   # Total effect
         '
fit <- sem(model, data = mediation.model,
           missing = 'fiml', fixed.x = F,
           se = "bootstrap",
           bootstrap = 1000)

# Display model output
summary(fit,standardized=TRUE, fit.measures = TRUE)

parameterEstimates(fit,
                   boot.ci.type = "bca.simple",
                   level = .95, ci = TRUE,
                   standardized = TRUE)

##Hypothesis 3 ------------------------------------------
  # X = HRV
  # M = SCS_TOTAL
  # W = AGE
  # Y = CESD_TOTAL

# Mean center variables
center_scale <- function(x) {
  scale(x, scale = FALSE)
}

center_scale(data)

# Create interaction term
data$interact <- data$SCS_TOTAL*data$AGE

# Moderated mediation model
Mod.Med.Lavaan <- 
  'SCS_TOTAL ~ a1*HRV + a2*AGE + a3*HRV:AGE
   CESD_TOTAL ~ c*HRV + c*AGE + c*HRV:AGE + b1*SCS_TOTAL

# Parameter estimate of mean of age
AGE ~ AGE.mean*1 #naming the parameter est of mean

# Parameter estimate of variance of age
AGE ~~ AGE.var*AGE #naming the parameter est of age

#Indirect effects conditional on moderator (a1 + a3*ModValue)*b1
indirect.SDbelow := (a1 + a3*(AGE.mean-sqrt(AGE.var)))*b1
indirect.SDabove := (a1 + a3*(AGE.mean+sqrt(AGE.var)))*b1

#Direct effects conditional on moderator (cdash1 + cdash3*ModValue)
direct.SDbelow := c + c*(AGE.mean-sqrt(AGE.var)) 
direct.SDabove := c + c*(AGE.mean+sqrt(AGE.var))

#Total effects conditional on moderator
total.SDbelow := direct.SDbelow + indirect.SDbelow
total.SDabove := direct.SDabove + indirect.SDabove

#Proportion mediated conditional on moderator
#To match the output of "mediate" package
prop.mediated.SDbelow := indirect.SDbelow / total.SDbelow
prop.mediated.SDabove := indirect.SDabove / total.SDabove

#Index of moderated mediation
  #An alternative way of testing if conditional indirect effects are 
  #significantly different from each other
index.mod.med := a3*b1
'

Mod.Med.SEM <- sem(model = Mod.Med.Lavaan,
                   data = data, 
                   missing = 'fiml', fixed.x = F,
                   se = "bootstrap",
                   bootstrap = 1000) 

# Display model output
summary(Mod.Med.SEM, standardized=TRUE, fit.measures = TRUE)

parameterEstimates(Mod.Med.SEM,
                   boot.ci.type = "bca.simple",
                   level = .95, ci = TRUE,
                   standardized = TRUE)

##Family-wise error correction (Holm correction)-------------------

# # Vector of un-adjusted p-values
# pvalues <- c(0.027,0.295,0.033,0.028,0.133,0.856,0.697,0.856,0.073,0.018)
#      #Key: H1, H2_Y~X, H2_M~X, H2_Y~M, H2_ab, H3_a1, H3_a2, H3_a3, H3_c, H3_b1
# 
# # Adjust p-values
# p.adjust(pvalues, method = "holm")
