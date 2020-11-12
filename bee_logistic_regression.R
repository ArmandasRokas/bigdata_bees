
setwd("/home/arm/Projects/bigdata_bees")
source("bee_my_functions.R")
library(BBmisc)


# Preprare train data
hive_data_daily_2020_jun <- import_hive_data_daily(from = "'2020-06-01 00:00:00'", to="'2020-07-01 00:00:00'")
weather_data_furesoe_2020_jun <- read.table(file="data/furesø-kommune-juni-2020.csv", sep="," ,header = TRUE)
weather_data_furesoe_2020_jun$dt <- as.Date(weather_data_furesoe_2020_jun$dt)
hive_data_2020_jun.train <- merge(hive_data_daily_2020_jun, weather_data_furesoe_2020_jun, by="dt")  

hive_data_2020_jun.train <- hive_data_2020_jun.train %>%  mutate(weight_delta = hive_weight_kgs_daily - dplyr::lag(hive_weight_kgs_daily)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
hive_data_2020_jun.train[1,"weight_delta"] <- 0.81
hive_data_2020_jun.train <- select(hive_data_2020_jun.train, !hive_weight_kgs_daily)

cor(hive_data_2020_jun.train[,-1])

hive_data_2020_jun.train <- hive_data_2020_jun.train %>%
  mutate(weight_delta_direction = ifelse(weight_delta<0, "DOWN", "UP"))

hive_data_2020_jun.train <- select(hive_data_2020_jun.train, !weight_delta)
hive_data_2020_jun.train <- select(hive_data_2020_jun.train, !dt)

hive_data_2020_jun.train$weight_delta_direction <- factor(hive_data_2020_jun.train$weight_delta_direction) 

# hive_data_2020_jun.train <- normalize(hive_data_2020_jun.train) #  not all algorithms are sensitive to magnitude in the way you suggest. Linear regression coefficients will be identical if you do, or don't, scale your data, because it's looking at proportional relationships between them.

# Prepare validate data
hive_data_daily_2019_jun <- import_hive_data_daily(from = "'2019-06-01 00:00:00'", to="'2019-07-01 00:00:00'")
weather_data_furesoe_2019_jun <- read.table(file="data/furesø-kommune-juni-2019.csv", sep="," ,header = TRUE)
weather_data_furesoe_2019_jun$dt <- as.Date(weather_data_furesoe_2019_jun$dt)
hive_data_2019_jun.validate <- merge(hive_data_daily_2019_jun, weather_data_furesoe_2019_jun, by="dt")  
hive_data_2019_jun.validate <- hive_data_2019_jun.validate %>%  mutate(weight_delta = hive_weight_kgs_daily - dplyr::lag(hive_weight_kgs_daily)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
hive_data_2019_jun.validate[1,"weight_delta"] <- 0.12

hive_data_2019_jun.validate <- select(hive_data_2019_jun.validate, !hive_weight_kgs_daily)

cor(hive_data_2019_jun.validate[,-1])

hive_data_2019_jun.validate <- hive_data_2019_jun.validate %>%
  mutate(weight_delta_direction =  ifelse(weight_delta<0, "DOWN", "UP"))

hive_data_2019_jun.validate <- select(hive_data_2019_jun.validate, !weight_delta)
hive_data_2019_jun.validate <- select(hive_data_2019_jun.validate, !dt)

hive_data_2019_jun.validate$weight_delta_direction <- factor(hive_data_2019_jun.validate$weight_delta_direction) 


#hive_data_2019_jun.validate <- normalize(hive_data_2019_jun.validate)


####### Predict with Logistic regression #######

# Fit only with ambient_temp_c_day_max
fit.logit <- glm(weight_delta_direction~ambient_temp_c_day_max   , data=hive_data_2020_jun.train, family=binomial())


#fit.logit <- glm(weight_delta_direction~. , data=hive_data_2020_jun.train, family=binomial()) # Does not work with normalized variables as well... 
# data is extremely skewed with outliers???? Thus you do not have perfect separation but the warning is occurring because some of the extreme observations have predicted probabilities indistinguishable from 1.
# https://stats.stackexchange.com/questions/396008/glm-fit-fitted-probabilities-numerically-0-or-1-occurred-however-culprit-featur
# Hvad finde nogee grænse værdier selv. Dvs om det regnet eller det var solen hele dag. 


summary(fit.logit)


prob <- predict(fit.logit, hive_data_2019_jun.validate, type="response")
logit.pred <- factor(prob>.5, levels=c(FALSE, TRUE), labels=c("DOWN", "UP"))
logit.perf <- table(hive_data_2019_jun.validate$weight_delta_direction, logit.pred, dnn=c("Actual", "Predicted"))
logit.perf

# Predicted
# Actual DOWN UP
# DOWN    6  4
# UP      3 17






####### K cross validation #######
library(caret) 
library(tidyverse) 
train_control <- trainControl(method = "cv",  
                              number = 5)  
# Train the model by assigning sales column  
# as target variable and the other columns  
# as independent varaibles.  
  set.seed(43534523523523)  
  model <- train(weight_delta_direction~ambient_temp_c_day_max, data = hive_data_2020_jun.train,   
                 method = "glm",  
                 trControl = train_control)
  print(model)
summary(model)


prob <- predict(model, hive_data_2019_jun.validate)
logit.perf <- table(hive_data_2019_jun.validate$weight_delta_direction, prob, dnn=c("Actual", "Predicted"))
logit.perf # Results is exactly the same as just by using glm()

# From K-cross validation, we can see that the model has .8 accurancy, which is little big higher than the validation 0.76,  23/30
# What does mean Kappa? 

# Predicted
# Actual DOWN UP
# DOWN    6  4
# UP      3 17




####### Predict with classical decision tree. ####### 

library(rpart)
dtree <- rpart(weight_delta_direction~ambient_temp_c_day_max, data=hive_data_2020_jun.train, method="class", parms=list(split="information"))
dtree <- rpart(weight_delta_direction~ ambient_temp_c_day_max + pressure, data=hive_data_2020_jun.train, method="class", parms=list(split="information"),
               control = rpart.control("minsplit" = 8))
dtree$cptable

library(rpart.plot)

prp(dtree, type=2, extra=104, fallen.leaves = TRUE)


dtree.pred <- predict(dtree, hive_data_2019_jun.validate, type="class" )
dtree.pref <- table(hive_data_2019_jun.validate$weight_delta_direction, dtree.pred, dnn=c("Actual", "Predicted"))
dtree.pref

# Virkeligt mærkeligt at den fravælger tempreture, og bruger pressure som den første


####### Conditional inference trees #######
install.packages("party")
library(party)
fit.ctree <- ctree(weight_delta_direction~ .,data=hive_data_2020_jun.train,  controls = ctree_control(mincriterion = 0.01, minsplit= 1, minbucket = 1))
fit.ctree
plot(fit.ctree)

ctree.pred <- predict(fit.ctree, hive_data_2019_jun.validate, type="response" )
ctree.pref <- table(hive_data_2019_jun.validate$weight_delta_direction, ctree.pred, dnn=c("Actual", "Predicted"))
ctree.pref
confusionMatrix(hive_data_2019_jun.validate$weight_delta_direction, ctree.pred) 
?ctree
# Until now the best results. Precipitation has very low p-value, but I would argue that it is important parameter that it bees do not fly when it rains heavely. 
# the most intresting thing, that pressure is one of the most significant variables. Is this just considence or there is documents some relationhsip there on the internet? 
# Pressure http://www.dave-cushman.net/bee/weathersense.html#:~:text=Honey%20bees%20can%20sense%20changes,directly%20linked%20to%20the%20storms.&text=So%2C%20if%20the%20wind%20is,a%20storm%20on%20the%20way.
#Predicted
#Actual DOWN UP
#DOWN    6  4
#UP      0 20

# Manual kfolds
k<- 5
folds<- sample(rep_len(1:k, nrow(hive_data_2020_jun.train)))
folds
table(folds)

Acc=c() # define accuracy vector
for(i in 1:k){
  Fit.ctree=ctree(weight_delta_direction~ .,data=hive_data_2020_jun.train[folds!=i,],  controls = ctree_control(mincriterion = 0.01, minsplit= 0, minbucket = 0))  # fit model on all folds except fold i
  pred=predict(Fit.ctree,newdata=hive_data_2020_jun.train[folds==i,])  # predict class for fold i
  Acc[i]=sum(pred==hive_data_2020_jun.train$weight_delta_direction[folds==i])/length(hive_data_2020_jun.train$weight_delta_direction[folds==i]) # accuracy for fold i
}
Acc
mean(Acc)
# Result not so impressive from K folds, so maybe not include into the report. 

# k fold http://www.just.edu.jo/~haalshraideh/Courses/IE759/DT3.html
fit <- train(weight_delta_direction~ . , data=hive_data_2020_jun.train, method="ctree", controls = ctree_control(mincriterion = 0.01, minsplit= 0, minbucket = 0), trControl=trainControl(method="cv", number=5), tuneLength=10 ) 
ctree.kfold.pred <- predict(fit, newData=hive_data_2019_jun.validate )
ctree.pref <- table(hive_data_2019_jun.validate$weight_delta_direction, ctree.kfold.pred, dnn=c("Actual", "Predicted"))
ctree.pref

plot(fit)
fit
fit$finalModel






fit.ctree <- ctree(weight_delta_direction~ .,data=hive_data_2019_jun.validate,  controls = ctree_control(mincriterion = 0.70, minsplit= 0, minbucket = 0))
plot(fit.ctree)

ctree.pred <- predict(fit.ctree,hive_data_2020_jun.train , type="response" )
ctree.pref <- table(hive_data_2020_jun.train$weight_delta_direction, ctree.pred, dnn=c("Actual", "Predicted"))
ctree.pref

confusionMatrix(hive_data_2020_jun.train$weight_delta_direction, ctree.pred) 
