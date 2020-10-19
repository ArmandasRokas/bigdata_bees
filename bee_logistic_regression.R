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




# Predict 

fit.logit <- glm(weight_delta_direction~ambient_temp_c_day_max , data=hive_data_2020_jun.train, family=binomial())
summary(fit.logit)

fit.logit <- glm(weight_delta_direction~. , data=hive_data_2020_jun.train, family=binomial())


prob <- predict(fit.logit, hive_data_2019_jun.validate, type="response")
logit.pred <- factor(prob>.5, levels=c(FALSE, TRUE), labels=c("DOWN", "UP"))
logit.perf <- table(hive_data_2019_jun.validate$weight_delta_direction, logit.pred, dnn=c("Actual", "Predicted"))
logit.perf