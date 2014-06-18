setwd("/Users/xuexue/kaggle/shopper/algoBenchmark")
options("scipen"=100, "digits"=10)
library(ROCR)
args <- commandArgs(trailingOnly = TRUE)
trainingfile <- args[1]
testfile <- args[2]

trainingfile <- '../interm/benchmarkFeaturesTrain'
testfile <- '../interm/benchmarkFeaturesTest'

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

formula <- paste0("repeater ~ ", paste(colnames(trainingdf)[1:37], collapse=" + "))

##### quantile regression -- this seems to give the best results!
library(quantreg)
model.qt <- rq(repeater ~ ., tau= .5, data=trainingdf)
pred.qt <- predict(model.qt, testdf)
pred.qt <- pmax(0, pmin(1, pred.qt))
performance(prediction(pred.qt, testdf$repeater), 'auc') # == 0.5963949198
# == 0.5946262694 (w/out 3)

##### dumb logistic regression model
#model.glm <- glm(repeater ~ ., data=trainingdf, family=binomial(link=logit))
#summary(model.glm)
#pred.glm <- predict(model.glm, testdf, type="response")
#performance(prediction(pred.glm, testdf$repeater), 'auc') # == 0.5039108188 (wtf?)
## == 0.5311540869 (w/out 3)

##### random forest
library(randomForest)
rfsubset <- trainingdf
# 30's
rfsubset$has_bought_category_company <- NULL
rfsubset$has_bought_category_brand <- NULL
rfsubset$has_never_bought_brand <- NULL
# 40's
#rfsubset$has_bought_company_brand <- NULL
#rfsubset$has_never_bought_company <- NULL
#rfsubset$has_bought_company_180 <- NULL
#rfsubset$has_bought_company_150 <- NULL
#rfsubset$has_bought_company_150 <- NULL
# 50's
#rfsubset$has_bought_brand_a <- NULL
#rfsubset$has_bought_brand_q <- NULL
#rfsubset$total_purchases <- NULL
model.rf <- randomForest(as.factor(repeater) ~ ., data=rfsubset, ntree=100, maxnodes=30, nodesize=5, importance=T)
pred.rf <- predict(model.rf, testdf, type="prob")[,"TRUE"]
performance(prediction(pred.rf, testdf$repeater), 'auc') 
# RESULT WITH "BEST SUBSET" OF THE FEATURES 
# 500/30/2 == 0.5897112426 (remove GINI < 40 from *) **
# 500/30/2 == 0.5887868002 (remove GINI < 50 from **)

# RESULT WITH "ALL" OF THE FEATURES
# 500/25/2 == 0.584597299
# 500/35/2 == 0.5853384781
# 500/30/2 == 0.5880069463*
# 50/30/2 == 0.5762595821
# 10/30/2 == 0.5707286909

# RESULT WITHOUT THREE OF THE FEATURES
# 500/30/2 == 0.5889198419
# 500/30/5 == 0.5859203503
# 500/30/10 == 0.5835576775
# 500/20/10 == 0.5805875231
# 100/20/10 == 0.5781540832
# 10/20/10 == 0.5729433792
# 5/20/10 == 0.5632263927
# 5/30/10 == 0.5595678066

##### COMBINATIONS

# READ SVM INPUT
pred.svm.train <- read.csv('../target/resultSVMTrainProb', header=T)$repeatProbability
pred.svm.test <- read.csv('../target/resultSVMTest', header=T)$repeatProbability
pred.svm.holdout<- read.csv('../target/resultSVMHoldoutProb', header=T)$repeatProbability
performance(prediction(pred.svm.test, testdf$repeater), 'auc')  # == 0.5979897535

pred.pysvm.train <- 1 - read.csv('../target/resultSVMTrainPY', header=T)$repeatProbability
pred.pysvm.test <- 1-read.csv('../target/resultSVMTestPY', header=T)$repeatProbability[15961:31921]
performance(prediction(pred.pysvm.test, testdf$repeater), 'auc')  # == 

## Linear combination
pred.comb.linear <- 0.5 * (pred.rf + pred.qt)
performance(prediction(pred.comb.linear, testdf$repeater), 'auc')  # == 0.6102466827

## GAM based on the result
df.comb.train <- data.frame(
  qt=predict(model.qt, trainingdf),
  rf=predict(model.rf, trainingdf, type="prob")[,"TRUE"],
  svm=pred.svm.train,
  pysvm=pred.pysvm.train,
  y=trainingdf$repeater)
df.comb.test <- data.frame(
  qt=pred.qt,
  rf=pred.rf,
  svm=pred.svm.test,
  y=testdf$repeater)
df.comb.holdout <- data.frame(
  qt=predict(model.qt, holdoutdf),
  rf=predict(model.rf, holdoutdf, type="prob")[,"TRUE"],
  svm=pred.svm.holdout,
  y=holdoutdf$repeater
)


library(mgcv)
comb.holdout.auc <- function(model) {
  pred <- predict(model, df.comb.holdout)
  pred <- pmin(1, pmax(0, pred))
  return(performance(prediction(pred, holdoutdf$repeater), 'auc'));
}

comb.holdout.auc(gam(y ~ s(qt) + s(rf), data=df.comb.test)) # 0.5924835565
comb.holdout.auc(gam(y ~ s(qt) + s(rf) + s(svm), data=df.comb.test)) # 0.5962423743
comb.holdout.auc(lm(y ~ qt + rf, data=df.comb.test)) # 0.5957286903
comb.holdout.auc(lm(y ~ qt + rf + svm, data=df.comb.test)) # 0.6131254921
comb.holdout.auc(lm(y ~ rf + svm, data=df.comb.test)) # 0.5920854824
comb.holdout.auc(glm(y ~ qt + rf, data=df.comb.test, family=binomial(link="logit"))) # 0.5451164022
comb.holdout.auc(glm(y ~ qt + rf + svm, data=df.comb.test, family=binomial(link="logit"))) # 0.542866535

comb.model <- lm(y ~ qt + rf + svm, data=rbind(df.comb.test, df.comb.holdout))
summary(comb.model)
pred <- predict(comb.model, df.comb.holdout)
pred <- pmin(1, pmax(0, pred))
summary(pred)
