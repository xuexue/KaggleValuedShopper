setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)
library(ROCR)
args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[1]
testfile <- args[2]

trainingfile <- '../interm/benchmarkFeaturesTrain'
testfile <- '../interm/benchmarkFeaturesTest'
outfile <- '../target/resultSVMTest'
outfiletrain <- '../target/resultSVMTrainProb'
outfileholdout <- '../target/resultSVMHoldoutProb'

deleteOldRows <- function(df) {
  df$repeater <- (as.character(df$repeater) == 't')
  return(df)
}

trainingdf <- read.csv(trainingfile, header=T)
trainingdf <- deleteOldRows(trainingdf)
trainingdf$id <- NULL
testdf <- read.csv(testfile, header=T)
testdf <- deleteOldRows(testdf)

holdoutdf <- testdf[1:15960,]
testdf <- testdf[15961:31921,]


##### SVM
library(e1071)
model.svm <- svm(as.factor(repeater) ~ ., data=trainingdf, probability=TRUE)


# test
pred.svm <- predict(model.svm, testdf, probability=TRUE)
pred.svm.prob <- attr(pred.svm, 'probabilities')[,1]
performance(prediction(pred.svm.prob, testdf$repeater), 'auc') 
output <- data.frame(id=testdf$id, repeatProbability=pred.svm.prob)
write.csv(output, file=outfile, row.names=FALSE, quote=FALSE)


# training
pred.svm.train <- predict(model.svm, trainingdf, probability=TRUE)
pred.svm.train.prob <- attr(pred.svm.train, 'probabilities')[,1]
trainingdf <- read.csv(trainingfile, header=T)
output <- data.frame(id=trainingdf$id, repeatProbability=pred.svm.train.prob)
write.csv(output, file=outfiletrain, row.names=FALSE, quote=FALSE)


# holdout
pred.svm.holdout <- predict(model.svm, holdoutdf, probability=TRUE)
pred.svm.holdout.prob <- attr(pred.svm.holdout, 'probabilities')[,1]
output <- data.frame(id=holdoutdf$id, repeatProbability=pred.svm.holdout.prob)
write.csv(output, file=outfileholdout, row.names=FALSE, quote=FALSE)

