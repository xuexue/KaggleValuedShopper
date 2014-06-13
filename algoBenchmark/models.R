setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)
library(ROCR)
args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[0]
testfile <- args[1]

trainingfile <- '../interm/benchmarkFeaturesTrain_'
testfile <- '../interm/benchmarkFeaturesTest_'

deleteOldRows <- function(df) {
  df$has_never_bought_companY_brand <- NULL
  df$has_never_bought_category_brand <- NULL
  df$has_never_bought_category_company <- NULL
  df$repeater <- (as.character(df$repeater) == 't')
  return(df)
}

trainingdf <- read.csv(trainingfile, header=T)
trainingdf <- deleteOldRows(trainingdf)
trainingdf$id <- NULL
testdf <- read.csv(testfile, header=T)
testdf <- deleteOldRows(testdf)

##### quantile regression -- this seems to give the best results!
library(quantreg)
model.qt <- rq(repeater ~ ., tau= .5, data=trainingdf)
pred.qt <- predict(model.qt, testdf)
pred.qt <- pmax(0, pmin(1, pred.qt))
performance(prediction(pred.qt, testdf$repeater), 'auc')  # == 0.5946262694 (w/out 3)

##### dumb logistic regression model
model.glm <- glm(repeater ~ ., data=trainingdf, family=binomial(link=logit))
summary(model.glm)
pred.glm <- predict(model.glm, testdf, type="response")
performance(prediction(pred.glm, testdf$repeater), 'auc') # == 0.5311540869

##### random forest
library(randomForest)
model.rf <- randomForest(as.factor(repeater) ~ ., data=trainingdf, ntree=500, maxnodes=30, nodesize=2, importance=T)
pred.rf <- predict(model.rf, testdf, type="prob")[,"TRUE"]
performance(prediction(pred.rf, testdf$repeater), 'auc') 

# RESULT WITHOUT THREE OF THE FEATURES
# 500/30/2 == 0.5889198419
# 500/30/5 == 0.5859203503
# 500/30/10 == 0.5835576775
# 500/20/10 == 0.5805875231
# 100/20/10 == 0.5781540832
# 10/20/10 == 0.5729433792
# 5/20/10 == 0.5632263927
# 5/30/10 == 0.5595678066

