# --- Cannabis & Epilepsy Data Analysis Script---
#   
# This script performs the following statistical analyses in R:
#   Descriptive statistics of demographics
#   Analysis 1: Fisher's exact test
#   Analysis 2: Cochran-Armitage test
#   Analysis 3: Exploratory comparisons
#   Analysis 4a: Fisher's exact test
#   Analysis 4b: Wilcoxon rank-sum test
#   Analysis 4c: Exploratory comparisons
#   
# Marielle L. Darwin | November 30 2021 | Last update: December 27 2021

# Install packages
install.packages('pastecs')
install.packages('ggplot2')
install.packages('ggstatsplot')
install.packages('DescTools')
install.packages('scales')

# Clear workspace
rm(list = ls())

# Set working directory
setwd("C:/Users/darwinm/Documents/Manuscripts/Cannabis & Epilepsy/Data")

# Load data
data <- read.csv("CannabisEpilepsy12.8.21.csv")

# Assign missing variables
data[data == 99] <- NA

# Split dataframe into subsets by refractory vs. non-refractory epilepsy
# Calculate frequency of 'Refractory' values
refractory_freq <- table(data$Refractory)

# Sort 'Refractory' column
newdata <- data[order(data$Refractory),]

# Split dataframe by 'Refractory' value
# Get rows of data
rows <- nrow(newdata)

# Create custom bins by number of rows where Refractory=0 
# In this case, n(Refractory=0)=24  
bins <- cut(1:rows, breaks = c(0,24,rows))
level_bins <- levels(bins)

# Print subsets of dataframe
for(i in 1:length(level_bins)) {    
  assign(paste0("newdata_", i),
         newdata[bins == levels(bins)[i], ])
}

# Retrieve dataframe subsets
View(newdata_1) # Refractory
View(newdata_2) # Non-refractory

###############################################################
##Descriptive statistics of demographics by subset group
###############################################################

# Age
library(pastecs)
# Refractory
age_ref <- stat.desc(newdata_2$Age)
round(age_ref, 2)
# Non-refractory
age_xref <- stat.desc(newdata_1$Age)
round(age_xref, 2)

# Race, sex, education, employment status (percentages)
# Refractory
sex_ref <- (prop.table(table(newdata_2$Sex)))*100
race_ref <- (prop.table(table(newdata_2$Race)))*100
ed_ref <- (prop.table(table(newdata_2$Education)))*100
employ_ref <- (prop.table(table(newdata_2$EmploymentStatus)))*100
# Non-refractory
sex_xref <- (prop.table(table(newdata_1$Sex)))*100
race_xref <- (prop.table(table(newdata_1$Race)))*100
ed_xref <- (prop.table(table(newdata_1$Education)))*100
employ_xref <- (prop.table(table(newdata_1$EmploymentStatus)))*100

###############################################################
## Analysis 1: Use of Cannabis
# Fisher's exact test will determine if the proportion of cannabis users 
# differed between people with refractory vs. non-refractory epilepsy. 
# Uses #CBD6 "Have you used cannabis in the past 12 months?" [Y/N]
###############################################################

# Contingency table reporting # of people in each subgroup
Analysis1 <- data.frame(
  "no_use" = c(25, 13), #(no_use/refractory, no_use/non-refractory)
  "use" = c(27, 11), #(use/refractory, use/non-refractory)
  row.names = c("Refractory", "Non-refractory"),
  stringsAsFactors = FALSE
)
colnames(Analysis1) <- c("Non-user", "User")

# Create dataframe from contingency table
x <- c()
for (row in rownames(Analysis1)) {
  for (col in colnames(Analysis1)) {
    x <- rbind(x, matrix(rep(c(row, col), 
                             Analysis1[row, col]), ncol = 2, byrow = TRUE))
  }
}
Analysis1_df <- as.data.frame(x)
colnames(Analysis1_df) <- c("Group", "Cannabis_use")

# Fisher's exact test 
test1 <- fisher.test(table(Analysis1_df))

# Combine boxplot and statistical test results
library(ggstatsplot)
ggbarstats(
  Analysis1_df, Cannabis_use, Group,
  results.subtitle = FALSE,
  subtitle = paste0(
    "Fisher's exact test", ", p-value = ",
    ifelse(test1$p.value < 0.001, "< 0.001", round(test1$p.value, 3))
  )
)

###############################################################
## Analysis 2: Frequency of Cannabis Use
# A Cochran-Armitage test for trend will determine if the frequency of cannabis
# use differed between people with refractory vs. non-refractory epilepsy. 
# Uses #CBD7 "In the past 12 months, how often have you used cannabis?" 
# [1 = Once a month or less; 2 = More than once a month; 3 = More than once 
# per week; 4 = Daily] 
###############################################################

# Proportion of use frequency (descriptive)
# Non-refractory
Freq_use_xref <- (prop.table(table(newdata_2$CBD7)))*100
# Refractory
Freq_use_ref <- (prop.table(table(newdata_1$CBD7)))*100

# Contingency table
Analysis2 <- data.frame(
  "refractory" = c(22, 11, 19, 48), #(%refractory/1, r/2, r/3, r/4)
  "non-refractory" = c(36, 18, 9, 36), #(%xrefractory/1, xr/2, xr/3, xr/4)
  row.names = c("Once a month or less", "> Once a month",
                "> Once per week", "Daily"),
  stringsAsFactors = FALSE
)
colnames(Analysis2) <- c("Refractory", "Non-refractory")

# Create dataframe from contingency table
x <- c()
for (row in rownames(Analysis2)) {
  for (col in colnames(Analysis2)) {
    x <- rbind(x, matrix(rep(c(row, col), 
                             Analysis2[row, col]), ncol = 2, byrow = TRUE))
  }
}
Analysis2_df <- as.data.frame(x)
colnames(Analysis2_df) <- c("Frequency", "Group")

# Visualize data with barplot
library(ggplot2)
library(scales)

ggplot(Analysis2_df) +
  aes(x = Frequency, fill = Group) +
  geom_bar(position = "dodge") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.minor = element_line(color = 1, size = 0.25, linetype = 1)
  )

# Cochran Armitage test for trend
library(DescTools)
freq_matrix <- matrix(c(36,18,9,36, 22,11,19,48), 
                      byrow=TRUE, nrow=2, dimnames=list(refractory=0:1, freq=1:4))

test2i <- CochranArmitageTest(freq_matrix, "increasing")
test2 <- CochranArmitageTest(freq_matrix)
test2d <- CochranArmitageTest(freq_matrix, "decreasing")

###############################################################
## Analysis 3: Method(s) of Cannabis Use
# An exploratory analysis will determine if the method(s) of cannabis
# use differed between people with refractory vs. non-refractory epilepsy. 
# Uses #CBD11, CBD11A, CBD12, CBD12A  
# [Joint/cigarette, Electronic cigarette/vape pen, Edible, Liquid 
# extract (oil), Transdermal (lotion, ointment, cream), concentrate 
# (dab/wax), Other (pipe, Epidiolex)] 
###############################################################

# Contingency table
Analysis3 <- data.frame(
  "refractory" = c(10,8,10,6,1,4,8,1), #(refractory/1, ... refractory/8)
  "non-refractory" = c(3,2,7,6,0,1,2,0), #(xrefractory/1, ... xrefractory/8)
  row.names = c("Joint/cigarette", "Electronic cigarette/vape pen", 
                "Edible", "Liquid extract", "Transdermal","Concentrate", 
                "Other (pipe)", "Other (Epidiolex)"),
  stringsAsFactors = FALSE
)
colnames(Analysis3) <- c("Refractory", "Non-refractory")

# Create dataframe from contingency table
x <- c()
for (row in rownames(Analysis3)) {
  for (col in colnames(Analysis3)) {
    x <- rbind(x, matrix(rep(c(row, col), 
                             Analysis3[row, col]), ncol = 2, byrow = TRUE))
  }
}
Analysis3_df <- as.data.frame(x)
colnames(Analysis3_df) <- c("Method", "Group")

# Visualize data with barplot
ggplot(Analysis3_df) +
  aes(x = Method, y = (..count..)/sum(..count..), fill = Group) +
  geom_bar(position = "dodge") +  scale_y_continuous(labels = percent) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.minor = element_line(color = 1, size = 0.25, linetype = 1)
  )

###############################################################
## Analysis 4: Reasons(s) for Cannabis Use
# A series of analyses will determine if the reasons(s) for cannabis
# use differed between people with refractory vs. non-refractory epilepsy. 
# 4a: Fisher's exact test
#   Uses #CBD18 "Do you believe using cannabis affects your seizure symptoms?" 
#   [Y/N/Unsure] 
# 4b: Wilcoxon Rank-Sum Test
#   Uses #CBD18A "How beneficial is cannabis on your seizure-related symptoms?"
#   [1=Absolutely beneficial; [2=Some benefit; 3=No effect; 4=Some harm;
#   5=Absolutely harmful]
# 4c: Exploratory comparisons
#   Uses #CBD18B & #CBD18C "What symptoms do you believe cannabis helps?" 
#   [Lowers seizure frequency; Lowers intensity of a seizure;
#   Reduces drowsiness after a seizure; Reduces headache after a seizure;  
#   Improves sore muscles after a seizure; Faster recovery; 
#   Other (Reduces distress); Other (Reduces nausea)]       
# For 4d: #CBD18D: Count of symptoms endorsed in #CBD18B and C
###############################################################

##Analysis 4a
# Contingency table
Analysis4a <- data.frame(
  "refractory" = c(14, 17, 13), #(ref/yes, ref/no, ref/unsure)
  "non-refractory" = c(2, 4, 7), #(xref/yes, xref/no, xref/unsure)
  row.names = c("Yes", "No", "Unsure"),
  stringsAsFactors = FALSE
)
colnames(Analysis4a) <- c("Refractory", "Non-refractory")
#View(Analysis4a)

# Create dataframe from contingency table
x <- c()
for (row in rownames(Analysis4a)) {
  for (col in colnames(Analysis4a)) {
    x <- rbind(x, matrix(rep(c(row, col), 
                             Analysis4a[row, col]), ncol = 2, byrow = TRUE))
  }
}
Analysis4a_df <- as.data.frame(x)
colnames(Analysis4a_df) <- c("Belief", "Group")

# Fisher's exact test 
test4a <- fisher.test(table(Analysis4a_df))

# Combine boxplot and statistical test results
ggbarstats(
  Analysis4a_df, Belief, Group,
  results.subtitle = FALSE,
  subtitle = paste0(
    "Fisher's exact test", ", p-value = ",
    ifelse(test4a$p.value < 0.001, "< 0.001", round(test4a$p.value, 3))
  )
)

##Analysis4b
# Contingency table
Analysis4b <- data.frame(
  "refractory" = c(9, 11, 11, 0, 0), #(refractory/1, r/2, r/3, r/4, r/5)
  "non-refractory" = c(3, 5, 4, 0, 0), #(xrefractory/1, xr/2, xr/3, xr/4, xr/5)
  row.names = c("Absolutely beneficial", "Some benefit", "No effect", 
                "Some harm", "Absolutely harmful"),
  stringsAsFactors = FALSE
)
colnames(Analysis4b) <- c("Refractory", "Non-refractory")
#View(Analysis4b)

# Create dataframe from contingency table
x <- c()
for (row in rownames(Analysis4b)) {
  for (col in colnames(Analysis4b)) {
    x <- rbind(x, matrix(rep(c(row, col), 
                             Analysis4b[row, col]), ncol = 2, byrow = TRUE))
  }
}
Analysis4b_df <- as.data.frame(x)
colnames(Analysis4b_df) <- c("Perceived_benefit", "Group")
#View(Analysis4b_df)

# Visualize data with: 
# Barplot
ggplot(Analysis4b_df) +
  aes(x = Group, fill = Perceived_benefit) +
  geom_bar(position = "dodge")

# Barplot with proportions
ggbarstats(Analysis4b_df, Perceived_benefit, Group)


# Wilcoxon Rank-Sum test
test4b <- wilcox.test(data$CBD18A ~ data$Refractory,
                      conf.int = TRUE, exact = FALSE)  

##Analysis 4c
# Contingency table
Analysis4c <- data.frame(
  "refractory" = c(12,7,2,10,8,6,2,1), #(refractory/1, ... refractory/8)
  "non-refractory" = c(3,4,1,4,1,3,2,0), #(xrefractory/1, ... xrefractory/8)
  row.names = c("Lowers frequency", "Lowers intensity",
                "Reduces drowsiness", "Reduces headache", 
                "Improves sore muscles","Faster recovery", 
                "Other (Reduces distress)", "Other (Reduces nausea)"),
  stringsAsFactors = FALSE
)
colnames(Analysis4c) <- c("Refractory", "Non-refractory")

# Create dataframe from contingency table
x <- c()
for (row in rownames(Analysis4c)) {
  for (col in colnames(Analysis4c)) {
    x <- rbind(x, matrix(rep(c(row, col), 
                             Analysis4c[row, col]), ncol = 2, byrow = TRUE))
  }
}
Analysis4c_df <- as.data.frame(x)
colnames(Analysis4c_df) <- c("Reason", "Group")

# Visualize data with barplot
ggplot(Analysis4c_df) +
  aes(x = Reason, y = (..count..)/sum(..count..), fill = Group) +
  geom_bar(position = "dodge") +  scale_y_continuous(labels = percent) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        panel.background = element_blank(),
        panel.grid.minor = element_line(color = 1, size = 0.25, linetype = 1)
  )

##Analysis 4d
# Descriptive statistics 
# Refractory
sx_ref <- stat.desc(newdata_2$CBD18D)
round(sx_ref, 2)
# Non-refractory
sx_xref <- stat.desc(newdata_1$CBD18D)
round(sx_xref, 2)