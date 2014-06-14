setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)
library(quantreg)

args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[1]
testfile <- args[2]
submitfile <- args[3]
outfile <- args[4]

trainingfile <- '../interm/benchmarkFeaturesTrain'
testfile <- '../interm/benchmarkFeaturesTest'
submitfile <- '../interm/benchmarkFeaturesSubmit'
outfile <- '../target/resultBenchmark'

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
pred.qt <- pmax(0, pmin(1, pred.qt))

output <- data.frame(id=submitdf$id, repeatProbability=pred.qt)
write.csv(output, file=outfile, row.names=FALSE, quote=FALSE)
