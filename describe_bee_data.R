
# Import data

selectDayQuery <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > '2020-06-26 00:00:00' AND 
                      hive_observation_time_local < '2020-06-27 00:00:00'", sep=" ") # No missing data. Pure data
selectWeekQuery <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > '2020-06-25 00:00:00' AND 
                      hive_observation_time_local < '2020-07-01 00:00:00'", sep=" ")
selectSummerQuery <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > '2020-05-15 00:00:00' AND 
                      hive_observation_time_local < '2020-08-01 00:00:00'", sep=" ")
selectYearQuery <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > '2019-09-01 00:00:00' AND 
                      hive_observation_time_local < '2020-09-01 00:00:00'", sep=" ")
selectYearQuery <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > '2019-09-01 00:00:00' AND 
                      hive_observation_time_local < '2020-09-01 00:00:00'", sep=" ")


hive_data <- importData(from = "'2019-06-06 00:00:00'", to="'2020-09-01 00:00:00'")

# Missing weights
sum(is.na(hive_data$hive_weight_kgs))
sum(na.omit(hive_data$hive_weight_kgs < 10.0)) # A hive cannot weight less than 10.0

# Count the number of missing timestamps in the dataset and extract rowids
library(dplyr)
hive_data <- hive_data %>%  mutate(timestamp_delta = hive_observation_time_local - dplyr::lag(hive_observation_time_local)) %>%
  mutate(timestamp_delta = ifelse(is.na(timestamp_delta), 0, timestamp_delta))
sum(hive_data$timestamp_delta > 7)
missing_timestamps_indeces <-hive_data[which(hive_data[,"timestamp_delta"] > 7),"rowid"]
missing_timestamps_timestamps <-hive_data[which(hive_data[,"timestamp_delta"] > 7),"hive_observation_time_local"]
missing_timestamps_timestamps
# Return weight deltas after missing timestamps
hive_data[which(hive_data[,"timestamp_delta"] > 7),c("hive_observation_time_local","weight_delta")]

# Find delta between every data points. Now it find delta for every 5 minutes, but it gives really small delta. Maybe change to 1 hour, one day or one week? The initial idea was to delete some points and leave out only for example midnight data, but maybe it can be smoothened as it described in Chapter 15 by taking avarage? 
library(dplyr)
?dplyr::lag
hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
plot(hive_data$hive_observation_time_local,hive_data$weight_delta , type="l")
summary(hive_data)
boxplot(hive_data$delta)

# Summary
summary(hive_data)
summary(hive_data$hive_observation_time_local)
summary(hive_data$hive_weight_kgs)

# Plot
plot_time_weight(hive_data)
## TODO plot against LUX, TEMPRATURE


# Find correlation between weight and temperature
selectQuery <- paste("SELECT hive_weight_kgs, ambient_temp_c from", table_name, "WHERE",id_field_name,  "=3"  , sep=" ")
sendQuery <- dbSendQuery(con, selectQuery )
hive_data <- dbFetch(sendQuery)
hive_data <- na.omit(hive_data)
cor(hive_data)






# Correlation 
cor(hive_data$hive_weight, hive_data$ambient_temperature)
plot(hive_data$ambient_temperature, hive_data$hive_weight, xlab="ambient_temperature", ylab="hive_weight")
