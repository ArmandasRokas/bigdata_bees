# If predictor variables are highly correlated, a random forest
# using conditional inference tress may provide better predictions.
#

library(party)
setwd("/home/arm/Projects/bigdata_bees")



# Prepare train data
hive_data_2020_jun.train <- import_hive_data_daily(from = "'2020-05-31 00:00:00'",
                                                   to="'2020-07-01 00:00:00'")
# Extract weight deltas
hive_data_2020_jun.train <- hive_data_2020_jun.train %>%  mutate(weight_delta = 
                                                                   hive_weight_kgs_daily - dplyr::lag(hive_weight_kgs_daily)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta)) %>%
  slice(2:n())
# Categorize weight delta directions
hive_data_2020_jun.train <- hive_data_2020_jun.train %>%
  mutate(weight_delta_direction = ifelse(weight_delta<0, "DOWN", "UP"))
hive_data_2020_jun.train$weight_delta_direction <- 
  factor(hive_data_2020_jun.train$weight_delta_direction) 
# Merge with weather data
weather_data_furesoe_2020_jun <- read.table(file="data/furesø-kommune-juni-2020.csv",
                                            sep="," ,header = TRUE)
weather_data_furesoe_2020_jun$dt <- as.Date(weather_data_furesoe_2020_jun$dt)
hive_data_2020_jun.train <- merge(hive_data_2020_jun.train,
                                  weather_data_furesoe_2020_jun, by="dt")  
# Remove not used columns
hive_data_2020_jun.train <- select(hive_data_2020_jun.train, 
                                   !c(hive_weight_kgs_daily,weight_delta, dt))


# Prepare validate data
hive_data_2019_jun.validate <- import_hive_data_daily(from = "'2019-05-31 00:00:00'", to="'2019-07-01 00:00:00'")
# Extract weight deltas
hive_data_2019_jun.validate <- hive_data_2019_jun.validate %>%  mutate(weight_delta = hive_weight_kgs_daily - dplyr::lag(hive_weight_kgs_daily)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta)) %>%
  slice(2:n())
# # Categorize weight delta directions
hive_data_2019_jun.validate <- hive_data_2019_jun.validate %>%
  mutate(weight_delta_direction =  ifelse(weight_delta<0, "DOWN", "UP"))
hive_data_2019_jun.validate$weight_delta_direction <-factor(hive_data_2019_jun.validate$weight_delta_direction) 
# Merge with weather data
weather_data_furesoe_2019_jun <- read.table(file="data/furesø-kommune-juni-2019.csv", sep="," ,header = TRUE)
weather_data_furesoe_2019_jun$dt <- as.Date(weather_data_furesoe_2019_jun$dt)
hive_data_2019_jun.validate <- merge(hive_data_2019_jun.validate, weather_data_furesoe_2019_jun, by="dt")  
# Remove not used columns
hive_data_2019_jun.validate <- select(hive_data_2019_jun.validate, !c(hive_weight_kgs_daily,weight_delta, dt))

######################## cforest ######################## 

hive_data_2019_2020 <- rbind(hive_data_2019_jun.validate, hive_data_2020_jun.train)
cf_2019_2020 <-cforest(weight_delta_direction~ .,data=hive_data_2019_2020,controls = cforest_control(mincriterion = 0.01, minsplit= 5, minbucket = 1))
cf_2019_2020.pred <- predict(cf_2019_2020, type="response", OOB=TRUE)
confusionMatrix(hive_data_2019_2020$weight_delta_direction, cf_2019_2020.pred)

pt <- prettytree(cf_2019_2020@ensemble[[1]], names(cf_2019_2020@data@get("input"))) 
nt <- new("BinaryTree") 
nt@tree <- pt 
nt@data <- cf_2019_2020@data 
nt@responses <- cf_2019_2020@responses 

plot(nt, type="simple")
# The same results as from one summer. 





?cforest
cf <- cforest(weight_delta_direction~ .,data=hive_data_2020_jun.train,controls = cforest_control(mincriterion = 0.01, minsplit= 1, minbucket = 1)) # 
cf
summary(cf)

ctree.pred <- predict(cf, newdata=hive_data_2019_jun.validate, type="response"  ) ## Error can not predict .
ctree.pred <- predict(cf, type="response", OOB=TRUE  ) 



## Try to findbetter reference on sample size
## Use both years data and use itseft to to check accurancy. 

confusionMatrix(hive_data_2019_jun.validate$weight_delta_direction, ctree.pred)

cf@predict_response()




pt <- prettytree(cf@ensemble[[1]], names(cf@data@get("input"))) 
nt <- new("BinaryTree") 
nt@tree <- pt 
nt@data <- cf@data 
nt@responses <- cf@responses 

plot(nt, type="simple")


######################## randomForest ########################

library(randomForest)
fit.forest <- randomForest(weight_delta_direction~ .,data=hive_data_2020_jun.train, importance=TRUE, nodesize=1)
importance(fit.forest, type=2)
plot(fit.forest)
?randomForest
forest.pred <- predict(fit.forest,hive_data_2019_jun.validate )
confusionMatrix(hive_data_2019_jun.validate$weight_delta_direction, forest.pred)


?randomForest




######################## Export data ########################
write.csv(hive_data_2019_2020,"hive_data_2019_2020.csv", row.names = FALSE)
write.csv(hive_data_2020_jun.train,"hive_data_2020_jun.train.csv", row.names = FALSE)
write.csv(hive_data_2019_jun.validate,"hive_data_2019_jun.validate.csv", row.names = FALSE)



