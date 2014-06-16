setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)

args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[1]
testfile <- args[2]
submitfile <- args[3]
outfile <- args[4]

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

library(e1071)
model.svm <- svm(as.factor(repeater) ~ ., data=fulldf, probability=TRUE)
pred.svm <- predict(model.svm, submitdf, probability=TRUE)
pred.svm.prob <- attr(pred.svm, 'probabilities')[,1]

output <- data.frame(id=submitdf$id, repeatProbability=pred.svm.prob)
write.csv(output, file=outfile, row.names=FALSE, quote=FALSE)
