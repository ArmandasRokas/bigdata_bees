
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



####### Predict with classical decision tree. ####### 






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


