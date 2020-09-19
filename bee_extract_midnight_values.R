source("bee_my_functions.R")
hive_data <- import_hive_data(from = "'2020-05-01 00:00:00'", to="'2020-09-01 00:00:00'")
periods_to_remove <- read.table(file="data/stade1_period_to_ignore_manipulate.csv", sep=",", header = TRUE)
hive_data <- manipulate_weight_deltas(hive_data=hive_data, periods=periods_to_remove)
plot_time_weight(hive_data, title="Den behandlede data")


library(dplyr)
library(lubridate)
install.packages("lubridate")

#hive_data %>% 
#  mutate(Date = ymd_hms(hive_observation_time_local), dt = as_date(hive_observation_time_local), hr = hour(hive_observation_time_local)) %>% 
#  group_by(dt, hr) %>% 
#  filter(Date == min(Date)) %>% 
#  ungroup() %>% 
#  select(Date, Val)
# hive_observation_time_local = ymd_hms(hive_observation_time_local),
hive_data <- hive_data %>% 
  mutate( dt = as.Date(hive_observation_time_local)) %>% 
  group_by(dt) %>%
  filter(hive_observation_time_local == min(hive_observation_time_local)) %>%
  ungroup() %>%
  select(!dt)#%>%
  #data.frame(hive_data)


# plot_time_weight(hive_data, title="Midnight values")
hive_data$hive_observation_time_local <-strptime(hive_data$hive_observation_time_local, format = "%Y-%m-%d %H:%M:%S")
paste(head(hive_data, 1)[,4])
plot(hive_data$hive_observation_time_local, hive_data$hive_weight_kgs, type = 'l' , ylab="Vægt")

hive_data <- data.frame(hive_data)
hive_data
?select

