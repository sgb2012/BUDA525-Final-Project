```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

Read in the data
```{r cache = TRUE}
#data<- read.table(file.choose(),sep="\t",header=T)

##first set path to /group/bprice5
### Image of how to
dat<- read.csv("/group/bprice5/1314C-08.CSV",header=T)
head(dat)
dim(dat)
```

```{r cache = TRUE}
#Additional packages
install.packages("dae") #Allows combining factors
library(dae)
install.packages("scales")
library(scales)
install.packages("gsubfn")
library(gsubfn)
install.packages("alr4")
library(alr4)
```

```{r}
#Subpopulations we want to work with
#SubPop 1. First Time Freshman
#Create subset of data with only First Time Freshmen (firstTimeFresh)
firstTimeFresh <- dat[which(dat$GS.ADMIT.TYPE.DESC == "First Time Freshman"),]
dim(firstTimeFresh)

#Can create other subpopulations if needed (grad students, seniors, etc)

#Dependent variables
#Personal attributes
#1. Gender (studentGender)
studentGender <- as.factor(firstTimeFresh$SEX.CODE)
summary(studentGender)
levels(studentGender)

#2. Ethnicity (studentEthn)
studentEthn <- factor(firstTimeFresh$ETHNIC.CODE, labels = c("White", "Black", "Hispanic", "Asian", "Native", "Unknown"))
summary(studentEthn)
levels(studentEthn)

#3. Major (degreeF)
degreeF <- firstTimeFresh$GS.DEGREE.DESC
summary(degreeF) #Shows degrees w/ 0 students in it
degreeF <- factor(degreeF) #Excludes unused levels 
summary(degreeF) #All majors have at least 1 student it in
levels(degreeF)

#4. Type of major (degreeType)
#Some majors are associates, and some are bachelors, want to split assocDegree and bachelDegree and otherDegree
assocDegree1 <- factor(degreeF == "Associate of Applied Sci")
assocDegree2 <- factor(degreeF == "Associate of Arts")
notDecDegree <- factor(degreeF == "Degree Not Declared")
regDegree <- factor(degreeF == "Regents Bachelor of Arts")

degreeType <- fac.combine(list(assocDegree1, assocDegree2, notDecDegree, regDegree))
degreeType <- factor(degreeType, labels = c("Bachelor Degree", "Regent Degree", "Degree Not Declared", "Associate Arts", "Associate Applied Sci"))
summary(degreeType)
levels(degreeType)

#Location attributes
#1. Student location by state (studentLoc)
studentLoc <- as.factor(firstTimeFresh$MAIL.STATE)
summary(studentLoc)
levels(studentLoc)
studentLoc <- factor(studentLoc) #remove unused levels
summary(studentLoc)
prop.table(table(studentLoc)) #50% of the students come from WV 

#2. In and out of state indicator (stateIndicator)
stateIndicator <- factor(studentLoc == "WV", labels = c("Out-of-State", "In-State"))
summary(stateIndicator)

#3. Proximity indicator (proxStudentType)
#Assumptions:
#In-state students will commute to Morgantown, the furthest out, the more the student will require assistance, after a certain distance, it makes no sense to commute and we can assume the student will move to Morgantown. 
#Assume the population from Monongalia will commute
#Assume the population from the following counties will also commute (~1 hour) and should be eligible for additional assistance: Preston, Taylor, Marion
#For all counties outside of this radius we assume would move to Morgantown

#Monongalia == shortCommuteStudent
#Preston, Taylor, Marion == longCommuteStudent
#Every other in-state counties == resStudent
shortCommuteStudent <- factor(firstTimeFresh$MAIL.CNTY.DESC == "Monongalia, WV")
longCommuteStudent <- factor(firstTimeFresh$MAIL.CNTY.DESC == "Preston, WV" | firstTimeFresh$MAIL.CNTY.DESC == "Taylor, WV" | firstTimeFresh$MAIL.CNTY.DESC == "Marion, WV")

summary(shortCommuteStudent) #1529
summary(longCommuteStudent) #227

proxStudentType <- fac.combine(list(shortCommuteStudent, longCommuteStudent))
summary(proxStudentType)
proxStudentType <- factor(proxStudentType, labels = c("Res or Out-of-State", "Long Commute", "Short Commute"))

#Affinity
affinityStatus <- as.factor(firstTimeFresh$LEGACY.DESC == "" | firstTimeFresh$LEGACY.DESC == "*No Family Member is Alumnus")
affinityStatus <- factor(affinityStatus, labels = c("Some Affinity", "No Affinity"))
summary(affinityStatus)

#Affordability attributes
expectedFamContrib <- rescale(firstTimeFresh$EXPECTED.TOT.FAM.CONT..EFC, to = c(0,100))
summary(expectedFamContrib)

#Academic Achievement attributes
#The academic achievement variables from the data are:
#HIGH.SCHOOL.GPA
#PREVIOUS.COLL.GPA
#HIGHEST.ACT.SUM.OF.STANDARD.SCORES
#SAT.TOTAL..HIGHEST.SMV.
#GED.SCORE

#Not all of these variables are ready for analysis, so this section will work on checking through each academic achievement variable and getting it ready.

#HIGH.SCHOOL.GPA
#go ahead and Weight the Unweighted HIGH.SCHOOL.GPAs from 0 to 5.0 instead of 0 to 4.0 while referencing WEIGHTED.GPA.IND variable.
highSchoolGPA <- ifelse((firstTimeFresh$WEIGHTED.GPA.IND=="NW") & (firstTimeFresh$HIGH.SCHOOL.GPA <=4), firstTimeFresh$HIGH.SCHOOL.GPA * 1.25, ifelse(firstTimeFresh$WEIGHTED.GPA.IND == "W", firstTimeFresh$HIGH.SCHOOL.GPA * 1, NA))

#PREVIOUS.COLL.GPA
#Need to mark the values that are greater than 4.0 as NA.  This is invalid information.
prevColGPA <- ifelse((firstTimeFresh$PREVIOUS.COLL.GPA > 4), NA, firstTimeFresh$PREVIOUS.COLL.GPA)

#HIGHEST.ACT.SUM.OF.STANDARD.SCORES
highestACT <- firstTimeFresh$HIGHEST.ACT.SUM.OF.STANDARD.SCORES

#SAT.TOTAL..HIGHEST.SMV.
totalSAT <- firstTimeFresh$SAT.TOTAL..HIGHEST.SMV.

#GED.SCORE
#remove the "G" from GED.SCORE to create a numeric value for scaling
scoreGED <- gsub("G", "", firstTimeFresh$GED.SCORE)
scoreGED <- as.numeric(as.character(scoreGED))
summary(scoreGED) # worked. Values 0 to 75.

#The 5 academic variables that we will use are:
#highSchoolGPA - Values 1.25 to 5.00
#prevColGPA - Values 0.00 to 4.00
#highestACT - Values 33 to 142
#totalSAT - Values 305 to 1600
#scoreGED - Values 0 to 75.

#Now that we have the 5 academic achievement variables formatted properly, we can scale the academic variables from 0 to 100 to create an even scale.
highSchoolGPA <- rescale(highSchoolGPA, to = c(1,100))
prevColGPA <- rescale(prevColGPA, to = c(1,100))
highestACT <- rescale(highestACT, to = c(1,100))
totalSAT <- rescale(totalSAT, to = c(1,100))
scoreGED <- rescale(scoreGED, to = c(1,100))

#The 5 academic achievement variables are now each on a percentile scale of 0 to 100. We just need to get the (count of which 5 academic variables in each row that are not NA) and use this to divide the (sum of the 5 academic variables in each row) to create the SCALED.ACADEMIC.ACHIEVEMENT variable that will be between 0 to 100 for each student.

# First Sum the 5 variables together
academAchievSum <- cbind.data.frame(highSchoolGPA, prevColGPA, highestACT, totalSAT, scoreGED)
academAchiev <- rowSums(academAchievSum[, c("highSchoolGPA", "prevColGPA", "highestACT", "totalSAT", "scoreGED")], na.rm = TRUE)
summary(academAchiev)

#Second get a count of NAs within the 5 variables by row.
countNA <- rowSums(is.na(academAchievSum[, c("highSchoolGPA", "prevColGPA", "highestACT", "totalSAT", "scoreGED")]))
summary(countNA)

#Create the SCALED.ACADEMIC.ACHIEVEMENT variable
scaledAcademAchiev <- academAchiev / (5 - countNA)
summary(scaledAcademAchiev)


#Independent variables
#Define 21 different grant types - this code only works for FTF, rework the code later to be able to work with any subpopulation we want
#Federal aid 
fedDirLoan_unsub <- firstTimeFresh$FED.DIRECT.LOAN....UNSUBSIDIZED
fedDirLoan_sub <- firstTimeFresh$FED.DIRECT.LOAN....SUBSIDIZED
fedDirPlus <- firstTimeFresh$FED.DIRECT.PLUS
fedPellGrant <- firstTimeFresh$FED.PELL.GRANT
fedSupOpp <- firstTimeFresh$FED.SUPPL.ED.OPP
fedOther <- firstTimeFresh$OTHER.FED.GRANTS.AND.SCHOLARS + firstTimeFresh$OTHER.FED.LOANS

#Misc grants 
miscGrants <- firstTimeFresh$MISC.GRANTS.AND.SCHOLARS
outOfStateGrant <- firstTimeFresh$OUT.OF.STATE.GRANTS.AND.SCHOLARS
medStudLoan <- firstTimeFresh$MED.STUDENT.LOAN

#WVU grants
rule49Grant <- firstTimeFresh$PROC..RULE.NO..49.GR...PR.TUI.FEE.WAIVS + firstTimeFresh$PROC..RULE.NO..49.UG.TUI.FEE.WAIV.ACAD + firstTimeFresh$PROC..RULE.NO..49.UG.TUI.FEE.WAIV.ATHL + firstTimeFresh$PROC..RULE.NO..49.UG.TUI.FEE.WAIV.NEED...OTHER
instEmployAid <- firstTimeFresh$INST.EMPLOYMENT
instGrantAcademic <- firstTimeFresh$INST.GRANTS.AND.SCHOLARS.ACADEMIC
instGrantAthletic <- firstTimeFresh$INST.GRANTS.AND.SCHOLARS.ATHLETIC
instGrantOther <- firstTimeFresh$INST.GRANTS.AND.SCHOLARS.OTHER

#West Virgina (state) grants
wvHigherEdGrant <- firstTimeFresh$WV.HIGHER.ED.GRANT.PROG
promScholars <- firstTimeFresh$PROMISE.SCHOLARS
wvOther <- firstTimeFresh$OTHER.WV.STATE.GRANTS.AND.SCHOLARS

#Build our data of independent and dependent variables
#WVU financial aid variables - will have to be combined into 1 independent variable
finDataTableWVU <- cbind.data.frame(rule49Grant, instEmployAid, instGrantAcademic, instGrantAthletic, instGrantOther)

#Calculate total WVU award pool
totalAwardWVU <- rule49Grant + instEmployAid + instGrantAcademic + instGrantAthletic + instGrantOther
sum(totalAwardWVU)
#The total WVU award amount for the years 2013-14 for first time freshman is 18.5$MM

#Calculate total non WVU award pool
totalAwardnonWVU <- fedDirLoan_unsub + fedDirLoan_sub + fedDirPlus + fedPellGrant + fedSupOpp  + fedOther + miscGrants + outOfStateGrant + medStudLoan + wvHigherEdGrant + promScholars + wvOther
sum(totalAwardnonWVU) #66.5$MM

#Calculate Promise Scholar award
totalAwardScholar <- promScholars
sum(totalAwardScholar) #7.5$MM

#Add the dependent variables to finDataTable
studentGender -> finDataTableWVU$studentGender
studentEthn -> finDataTableWVU$studentEthn
degreeF -> finDataTableWVU$degreeF
degreeType -> finDataTableWVU$degreeType
studentLoc -> finDataTableWVU$studentLoc
stateIndicator -> finDataTableWVU$stateIndicator
proxStudentType -> finDataTableWVU$proxStudentType
highSchoolGPA -> finDataTableWVU$highSchoolGPA
prevColGPA -> finDataTableWVU$prevColGPA
highestACT -> finDataTableWVU$highestACT
totalSAT -> finDataTableWVU$totalSAT
scoreGED -> finDataTableWVU$scoreGED
scaledAcademAchiev -> finDataTableWVU$scaledAcademAchiev
affinityStatus -> finDataTableWVU$affinityStatus
expectedFamContrib -> finDataTableWVU$expectedFamContrib

summary(finDataTableWVU)

#add totalAwardWVU, totalAwardnonWVU to our finDataWVU table
totalAwardWVU -> finDataTableWVU$totalAwardWVU
totalAwardnonWVU -> finDataTableWVU$totalAwardnonWVU
totalAwardScholar -> finDataTableWVU$totalAwardPromScholar
summary(finDataTableWVU)
names(finDataTableWVU)

#Identify subset of students that received WVU aid, Other aid, are Promise students
aidStudentWVU <- factor(finDataTableWVU$totalAwardWVU > 0, labels = c("Did not received WVU aid", "Received WVU aid"))
aidStudentnonWVU <- factor(finDataTableWVU$totalAwardnonWVU > 0, labels = c("Did not received other aid", "Received other aid"))
aidStudentPromScholar <- factor(finDataTableWVU$totalAwardPromScholar > 0, labels = c("Is not Promise", "Is Promise"))

aidStudentWVU -> finDataTableWVU$aidStudentWVU
aidStudentnonWVU -> finDataTableWVU$aidStudentnonWVU
aidStudentPromScholar -> finDataTableWVU$aidStudentPromScholar

#create new table with only students that have been awarded > 4000
finDataTableWVU_AL1 <- subset(finDataTableWVU, totalAwardWVU > 40000)
summary(finDataTableWVU_AL1)

#AL2
finDataTableWVU_AL2 <- subset(finDataTableWVU, totalAwardWVU > 20000 & totalAwardWVU <= 40000)
summary(finDataTableWVU_AL2)

#AL3
finDataTableWVU_AL3 <- subset(finDataTableWVU, totalAwardWVU > 10000 & totalAwardWVU <= 20000)
summary(finDataTableWVU_AL3)

#AL4
finDataTableWVU_AL4 <- subset(finDataTableWVU, totalAwardWVU > 5000 & totalAwardWVU <= 10000)
summary(finDataTableWVU_AL4)

#AL5
finDataTableWVU_AL5 <- subset(finDataTableWVU, totalAwardWVU > 1000 & totalAwardWVU <= 5000)
summary(finDataTableWVU_AL5)

#AL6
finDataTableWVU_AL6 <- subset(finDataTableWVU, totalAwardWVU > 500 & totalAwardWVU <= 1000)
summary(finDataTableWVU_AL6)

#AL7  
finDataTableWVU_AL7 <- subset(finDataTableWVU, totalAwardWVU > 100 & totalAwardWVU <= 500)
summary(finDataTableWVU_AL7)

#AL8  
finDataTableWVU_AL8 <- subset(finDataTableWVU, totalAwardWVU > 0 & totalAwardWVU <= 100)
summary(finDataTableWVU_AL8)

#Descriptive stats

#create a function to summarize mean of the data
summaryTable <- function(a = NULL, table1 = NULL, list1 = list(studentGender), func = mean) {
  table1 <- tapply(a, list1, func)
  print(table1)
} 

#Student attributes
#studentGender, studentEthn, degreeF, degreeType, studentLoc, stateIndicator, proxStudentType

for(i in 13:15){
  print(colnames(finDataTableWVU[i]))
  summaryTable(finDataTableWVU[,i], list1, func = mean)
  writeLines("")
}

names(finDataTableWVU)
summary(finDataTableWVU)


```


Now deal with the blank values and NA's on variables within the finDataTableWVU dataset so that we can model these without excluding too many.
```{r}

finDataTableWVU$highSchoolGPA.NA <- is.na(finDataTableWVU$highSchoolGPA)
finDataTableWVU$prevColGPA.NA <- is.na(finDataTableWVU$prevColGPA)
finDataTableWVU$highestACT.NA <- is.na(finDataTableWVU$highestACT)
finDataTableWVU$totalSAT.NA <- is.na(finDataTableWVU$totalSAT)
finDataTableWVU$scoreGED.NA <- is.na(finDataTableWVU$scoreGED)
finDataTableWVU$expectedFamContrib.NA <- is.na(finDataTableWVU$expectedFamContrib)
finDataTableWVU$studentEthn.NA <-is.na(finDataTableWVU$studentEthn)
finDataTableWVU$scaledAcademAchiev.NA <-is.na(finDataTableWVU$scaledAcademAchiev)

finDataTableWVU$highSchoolGPA[is.na(finDataTableWVU$highSchoolGPA)] = 1
finDataTableWVU$prevColGPA[is.na(finDataTableWVU$prevColGPA)] = 1
finDataTableWVU$highestACT[is.na(finDataTableWVU$highestACT)] = 1
finDataTableWVU$totalSAT[is.na(finDataTableWVU$totalSAT)] = 1
finDataTableWVU$scoreGED[is.na(finDataTableWVU$scoreGED)] = 1
finDataTableWVU$expectedFamContrib[is.na(finDataTableWVU$expectedFamContrib)] = 1
finDataTableWVU$studentEthn[is.na(finDataTableWVU$studentEthn)] = "Unknown"
finDataTableWVU$scaledAcademAchiev[is.na(finDataTableWVU$scaledAcademAchiev)] = 1
summary(finDataTableWVU)
```

```{r}
#model transformation
#To avoid problems with negative values of the response variable, we add 0.5 to all observations
pred <- finDataTableWVU$totalAwardWVU + 0.5

modWVUAid <- lm(sqrt(pred) ~ studentGender + studentEthn + degreeF + proxStudentType + affinityStatus + expectedFamContrib + expectedFamContrib.NA + aidStudentnonWVU + aidStudentWVU + aidStudentPromScholar + affinityStatus + highestACT + highestACT.NA + totalSAT + totalSAT.NA + totalAwardnonWVU + totalAwardPromScholar, data = finDataTableWVU)

require(MASS)
bc <- boxcox(modWVUAid)
#The optimal transformation has a parameter close to -2

#find the approximate mle as the x-value that yields the maximum
bc$x[bc$y==max(bc$y)]

#call the function with a single parameter value to just evaluate the log-likelihood
bc0 <- boxcox(modWVUAid, lambda = 1, plotit = TRUE) 
bc1 <- boxcox(modWVUAid, lambda = 0, plotit = TRUE) 
bc2 <- boxcox(modWVUAid, lambda = 2, plotit = TRUE) 
bc3 <- boxcox(modWVUAid, lambda = -1, plotit = TRUE)
bc4 <- boxcox(modWVUAid, lambda = -2, plotit = TRUE)




TukeyHSD(aov(modWVUAid), ordered = TRUE, conf.level = 0.99, "proxStudentType")

summary(modWVUAid)
ncvTest(modWVUAid)
plot(modWVUAid)
mmp(modWVUAid)

summary.aov(modWVUAid)
plot(totalAwardWVU ~ modWVUAid$fitted.values)

#Other model approach:
totalAwardWVUMod3 <- lm(sqrt(totalAwardWVU) ~ studentGender + studentEthn + degreeF + degreeType + studentLoc + stateIndicator + proxStudentType + scaledAcademAchiev + affinityStatus + expectedFamContrib, data = finDataTableWVU)
summary(totalAwardWVUMod3)
ncvTest(totalAwardWVUMod3)
plot(totalAwardWVUMod3)
mmp(totalAwardWVUMod3)

par(mfrow = c(1, 2))
plot(log(totalAwardWVU) ~ modWVUAid$fitted.values)
plot(log(totalAwardWVU) ~ totalAwardWVUMod3$fitted.values)

par(mfrow = c(1, 2))
mmp(modWVUAid, sd = TRUE)
mmp(totalAwardWVUMod3, sd = TRUE)


#test model predictions 
names(finDataTableWVU)
which(finDataTableWVU[,21] > 40000)
fitResults <- predict(modWVUAid, newdata = finDataTableWVU[1355,], type = "response")
(fitResults)^2
finDataTableWVU[1355, 21]

#Unfortunately while the models fit that data well, testing it with the predictions about show that the results do not seem to accurately predict totalAwardWVU
```


Modeling students who received no WVU direct aid with those who did receive WVU aid created mixed results and lowered the quality of the prediction.  By modelling them separately, we can provide better insight to the university.

By modeling just the population that did receive at least some totalAwardWVU we will get more accurate predicitors.  With this, we can see what variables were important for increasing the amount of WVU aid that the university decided to issue to a student.
```{r}

#run model on subset of students that received WVU aid #AL12 Total WVU Award > 0 

finDataTableWVU_AL12 <- subset(finDataTableWVU, totalAwardWVU > 0) 
dim(finDataTableWVU_AL12) 
summary(finDataTableWVU_AL12)
sum(finDataTableWVU_AL12$totalAwardWVU)

modWVUAid_1 <- lm(totalAwardWVU ~ studentGender + studentEthn + degreeF + studentLoc + proxStudentType + affinityStatus + expectedFamContrib + expectedFamContrib.NA + aidStudentnonWVU + aidStudentPromScholar + highestACT + highestACT.NA + totalSAT + totalSAT.NA + totalAwardnonWVU + totalAwardPromScholar + highSchoolGPA + highSchoolGPA.NA + prevColGPA + prevColGPA.NA + scoreGED + scoreGED.NA + scaledAcademAchiev, data = finDataTableWVU_AL12)

summary(modWVUAid_1)
anova(modWVUAid_1) #promScholar aid, prevColGPA, scoreGED, and scaledAcademAchiev amount is not sig

modWVUAid_2 <- lm(totalAwardWVU ~ studentGender + studentEthn + degreeF + studentLoc + proxStudentType + affinityStatus + expectedFamContrib + expectedFamContrib.NA + aidStudentnonWVU + aidStudentPromScholar + highSchoolGPA + highSchoolGPA.NA + highestACT + highestACT.NA + totalSAT + totalSAT.NA + totalAwardnonWVU, data = finDataTableWVU_AL12) 

summary(modWVUAid_2) 
anova(modWVUAid_2)

#model transformation require(MASS) bc <- boxcox(modWVUAid_2) 
#The optimal transformation has a parameter close to 0 - use log

#find the approximate mle as the x-value that yields the maximum bc$x[bc$y==max(bc$y)]

modWVUAid_3 <- lm(log(totalAwardWVU) ~ studentGender + studentEthn + degreeF + studentLoc + proxStudentType + affinityStatus + expectedFamContrib + expectedFamContrib.NA + aidStudentnonWVU + aidStudentPromScholar + highestACT + highestACT.NA + totalSAT + totalSAT.NA + totalAwardnonWVU, data = finDataTableWVU_AL12) 
summary(modWVUAid_3)
anova(modWVUAid_3)


ncvTest(modWVUAid_3) 
plot(modWVUAid_3) 
mmp(modWVUAid_3, sd = TRUE)
residualPlot(modWVUAid_3)
summary(modWVUAid_3)


#test model predictions
names(finDataTableWVU_AL12)
which(finDataTableWVU_AL12[,21] > 40000)
fitResults <- predict(modWVUAid_3, newdata = finDataTableWVU_AL12[813,], type = "response")
exp(fitResults)
finDataTableWVU_AL12[813, 21]

finDataTableWVU_AL12$predictedAwardWVU <-exp(predict(modWVUAid_3))
```