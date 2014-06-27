setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)

args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[1]
testfile <- args[2]
submitfile <- args[3]
outfile1 <- args[4]
outfile2 <- args[5]

deleteOldRows <- function(df) {
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

IDS <- fulldf$id
fulldf$id <- NULL
submitdf <- read.csv(submitfile, header=T)

library(e1071)
model.svm <- svm(as.factor(repeater) ~ ., data=fulldf, probability=TRUE)

pred.svm.train <- predict(model.svm, fulldf, probability=TRUE)
pred.svm.train.prob <- attr(pred.svm.train, 'probabilities')[,1]
output1 <- data.frame(id=IDS, repeatProbability=pred.svm.train.prob)
write.csv(output1, file=outfile1, row.names=FALSE, quote=FALSE)

pred.svm <- predict(model.svm, submitdf, probability=TRUE)
pred.svm.prob <- attr(pred.svm, 'probabilities')[,1]
output2 <- data.frame(id=submitdf$id, repeatProbability=pred.svm.prob)
write.csv(output2, file=outfile2, row.names=FALSE, quote=FALSE)
