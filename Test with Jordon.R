```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


```{r}
data<- read.table(file.choose(),sep="\t",header=T)

##first set path to /group/bprice5
### Image of how to
data<- read.csv("/group/bprice5/1314C-08.CSV",header=T)
head(data)
dim(data)
```

#Now deal with the blank values and NA's on Academic Achievement variables within the "data" dataset
```{r}
data$WEIGHTED.GPA.IND.NA <- is.na(data$WEIGHTED.GPA.IND)
data$HIGH.SCHOOL.GPA.NA <- is.na(data$HIGH.SCHOOL.GPA)
data$PREVIOUS.COLL.GPA.NA <- is.na(data$PREVIOUS.COLL.GPA)
data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES.NA <- is.na(data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES)
data$SAT.TOTAL..HIGHEST.SMV..NA <- is.na(data$SAT.TOTAL..HIGHEST.SMV.)
data$GED.SCORE.NA <- is.na(data$GED.SCORE)

data$WEIGHTED.GPA.IND[is.na(data$WEIGHTED.GPA.IND)] = 0
data$HIGH.SCHOOL.GPA[is.na(data$HIGH.SCHOOL.GPA)] = 0
data$PREVIOUS.COLL.GPA[is.na(data$PREVIOUS.COLL.GPA)] = 0
data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES[is.na(data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES)] = 0
data$SAT.TOTAL..HIGHEST.SMV.[is.na(data$SAT.TOTAL..HIGHEST.SMV.)] = 0
data$GED.SCORE[is.na(data$GED.SCORE)] = 0
```

```{r}
install.packages("scales")
library(scales)
```
```{r}
data$WEIGHTED.GPA.IND.PERCENTILE<-rescale(data$WEIGHTED.GPA.IND, to = c(0,100))
head(data$WEIGHTED.GPA.IND.PERCENTILE)
print(data$WEIGHTED.GPA.IND.PERCENTILE)
```

```{r}
data$HIGH.SCHOOL.GPA.PERCENTILE<-rescale(data$HIGH.SCHOOL.GPA, to = c(0,100))
head(data$HIGH.SCHOOL.GPA.PERCENTILE)
print(data$HIGH.SCHOOL.GPA.PERCENTILE)
```

```{r}
data$PREVIOUS.COLL.GPA.PERCENTILE<-rescale(data$PREVIOUS.COLL.GPA, to = c(0,100))
head(data$PREVIOUS.COLL.GPA.PERCENTILE)
print(data$PREVIOUS.COLL.GPA.PERCENTILE)
```

```{r}
data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES.PERCENTILE<-rescale(data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES, to = c(0,100))
head(data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES.PERCENTILE)
print(data$HIGHEST.ACT.SUM.OF.STANDARD.SCORES.PERCENTILE)
```

```{r}
data$SAT.TOTAL..HIGHEST.SMV.PERCENTILE<-rescale(data$SAT.TOTAL..HIGHEST.SMV., to = c(0,100))
head(data$SAT.TOTAL..HIGHEST.SMV.PERCENTILE)
print(data$SAT.TOTAL..HIGHEST.SMV.PERCENTILE)
```

```{r}
head(data$GED.SCORE)
summary(data$GED.SCORE)
summary(data$GED.SCORE.NA)
```