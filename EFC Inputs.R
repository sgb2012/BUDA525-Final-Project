```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r cache = TRUE}
data<- read.csv("/group/bprice5/1314C-08.CSV",header=T)
head(data)
dim(data)
```

```{r}
install.packages("scales")
library(scales)
```

```{r}
names(dat)
```

```{r}
head(data$EXPECTED.TOT.FAM.CONT..EFC)
str(data$EXPECTED.TOT.FAM.CONT..EFC)
summary(data$EXPECTED.TOT.FAM.CONT..EFC)
```

```{r}
hist(data$EXPECTED.TOT.FAM.CONT..EFC,
     main="Expected Family Contribution",
     xlab="Dollars",
     xlim=c(0,100000),
     las=1,
     breaks=5)
```

```{r}
is.numeric(data$EXPECTED.TOT.FAM.CONT..EFC.)
is.na(data$EXPECTED.TOT.FAM.CONT..EFC.)
is.null(data$EXPECTED.TOT.FAM.CONT..EFC.)
is.logical(data$EXPECTED.TOT.FAM.CONT..EFC.)
```

```{r}`
data$EXPECTED.TOT.FAM.CONT..EFC.PERCENTILE<-rescale(data$EXPECTED.TOT.FAM.CONT..EFC, to = c(0,100))
summary(data$EXPECTED.TOT.FAM.CONT..EFC.PERCENTILE)
```