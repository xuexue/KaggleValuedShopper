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
pred.qt <- predict(model.qt, submitdf, type="response")
pred.qt <- pmax(0, pmin(1, pred.qt))

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
model.rf <- randomForest(as.factor(repeater) ~ ., data=rfsubset, ntree=500, maxnodes=30, nodesize=5, importance=T)
pred.rf <- predict(model.rf, submitdf, type="prob")[,"TRUE"]
rm(rfsubset)

##### read svm results
pred.svm=read.csv('../target/resultSVMR', header=T)$repeatProbability

##### COMBINATIONS
pred.comb <- 0.08663332 + 3.71910523*pred.qt + 0.19873516*pred.rf + 0.62873995*pred.svm # coefficients from training data

output <- data.frame(id=submitdf$id, repeatProbability=pred.comb)
write.csv(output, file=outfile, row.names=FALSE, quote=FALSE)
