setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)
library(quantreg)
library(randomForest)

args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[1]
testfile <- args[2]
submitfile <- args[3]
outfile <- args[4]

#trainingfile <- '../interm/benchmarkFeaturesTrain'
#testfile <- '../interm/benchmarkFeaturesTest'
#submitfile <- '../interm/benchmarkFeaturesSubmit'
#outfile <- '../target/resultBenchmark'

deleteOldRows <- function(df) {
  df$id <- NULL
  df$repeater <- (as.character(df$repeater) == 't')
  return(df)
}

trainingdf <- read.csv(trainingfile, header=T)
trainingdf <- deleteOldRows(trainingdf)
testdf <- read.csv(testfile, header=T)
testdf <- deleteOldRows(testdf)
fulldf <- rbind(trainingdf, testdf)
rm(trainingdf)
rm(testdf)

submitdf <- read.csv(submitfile, header=T)

##### quantile regression
model.qt <- rq(repeater ~ ., tau= .5, data=fulldf)
pred.qt <- predict(model.qt, submitdf)

##### random forrest
rfsubset <- fulldf
rfsubset$has_bought_category_company <- NULL
rfsubset$has_bought_category_brand <- NULL
rfsubset$has_never_bought_brand <- NULL
rfsubset$has_bought_company_brand <- NULL
rfsubset$has_never_bought_company <- NULL
rfsubset$has_bought_company_180 <- NULL
rfsubset$has_bought_company_150 <- NULL
rfsubset$has_bought_company_150 <- NULL
model.rf <- randomForest(as.factor(repeater) ~ ., data=rfsubset, ntree=500, maxnodes=30, nodesize=2, importance=T)
pred.rf <- predict(model.rf, submitdf, type="prob")[,"TRUE"]
rm(rfsubset)

##### COMBINATIONS
df.comb.train <- data.frame(
  qt=predict(model.qt, fulldf),
  rf=predict(model.rf, fulldf, type="prob")[,"TRUE"],
  y=fulldf$repeater
)
df.comb.submit <- data.frame(qt=pred.qt, rf=pred.rf)

model.comb.glm <- glm(y ~ qt + rf, data=df.comb.train, family=binomial(link="logit"))
pred.comb.glm <- predict(model.comb.glm, df.comb.submit, type="response")

output <- data.frame(id=submitdf$id, repeatProbability=pred.comb.glm)
write.csv(output, file=outfile, row.names=FALSE, quote=FALSE)
