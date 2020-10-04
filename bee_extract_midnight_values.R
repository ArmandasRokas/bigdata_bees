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

hive_data <- import_hive_data(from = "'2020-05-01 00:00:00'", to="'2020-09-01 00:00:00'")

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


## Extract midt days values


hive_data <- hive_data %>% 
  mutate( dt = as.Date(hive_observation_time_local)) %>% 
  group_by(dt) %>% 
  mutate(hm = format(hive_observation_time_local,"%H:%M") )


hive_data[hive_data$hm="12:00",]

hive_data[which(hive_data[,"hm"]=="12:00"),]
hive_data <- hive_data[which(hive_data[,"hm"]=="12:00"),]
extract_rows_given_timedelta(hive_data[which(hive_data[,"hm"]=="12:00"),], 1)



# Max temp. Tested for missing values in period maj-aug
hive_data <- import_hive_data(from = "'2020-04-30 00:00:00'", to="'2020-09-01 00:00:00'")

# Find max daily temprature
hive_data_temp <- hive_data %>% 
  mutate( dt = as.Date(hive_observation_time_local)) %>% 
  group_by(dt) %>%
  filter(ambient_temp_c == max(ambient_temp_c)) %>%
  ungroup() %>%
  distinct(dt, .keep_all = TRUE) %>%
  select(dt ,ambient_temp_c) %>%
  mutate(ambient_temp_c =  dplyr::lag(ambient_temp_c)) %>% # Move max daily weight values one row backwards, so it fits daily weight 
  slice(2:n())
# prev_day_max_ambient_temp_c
hive_data_temp <- rename(hive_data_temp, ambient_temp_c_prev_day_max = ambient_temp_c )

hive_data <- hive_data %>% 
  mutate( dt = as.Date(hive_observation_time_local)) %>% 
  group_by(dt) %>%
  filter(hive_observation_time_local == min(hive_observation_time_local)) %>%
  ungroup() %>%
  select(!ambient_temp_c) #%>%
  #select(!dt)

hive_data <- merge(hive_data, hive_data_temp, by="dt")  

hive_data <- hive_data %>%
  select(!dt)

from <- '2020-05-01 00:00:00'
substr(as.POSIXlt(from)+1-60*60*24, 1, 19)



hive_data_temp_lagged <- hive_data_temp
hive_data_temp_lagged$ambient_temp_c <- dplyr::lag(hive_data_temp_lagged$ambient_temp_c)
hive_data_temp_lagged<- hive_data_temp_lagged[-1,]





# Function returns daily values, where a daily weight is a midnight value and a daily ambient temp is a previous day maximum value. 
import_hive_data_daily<- function(from, to){
  
  from <- substr(from,2,20)
  from <- paste("'", substr(as.POSIXlt(from)-1-60*60*24, 1, 19), "'", sep="") # Change from date to import one day before
  hive_data <- import_hive_data(from, to)
  
  # Manipulate weight deltas
  periods_to_remove <- read.table(file="data/stade1_period_to_ignore_manipulate.csv", sep=",", header = TRUE)
  hive_data <- manipulate_weight_deltas(hive_data=hive_data, periods=periods_to_remove)
  
  # Find max daily temprature values
  hive_data_temp <- hive_data %>% 
    mutate( dt = as.Date(hive_observation_time_local)) %>% 
    group_by(dt) %>%
    filter(ambient_temp_c == max(ambient_temp_c)) %>%
    ungroup() %>%
    distinct(dt, .keep_all = TRUE) %>%
    select(dt ,ambient_temp_c) %>%
    mutate(ambient_temp_c =  dplyr::lag(ambient_temp_c)) %>% # Move max daily weight values one row backwards, so it fits daily weight 
    slice(2:n())
  
  hive_data_temp <- rename(hive_data_temp, ambient_temp_c_prev_day_max = ambient_temp_c )
  
  # Find midnight weight values 
  hive_data <- hive_data %>% 
    mutate( dt = as.Date(hive_observation_time_local)) %>% 
    group_by(dt) %>%
    filter(hive_observation_time_local == min(hive_observation_time_local)) %>%
    ungroup() %>%
    select(!ambient_temp_c) #%>%
  
  # Merge midnight weight and max daily temp
  hive_data <- merge(hive_data, hive_data_temp, by="dt")  
  
  # Remove dt column
  hive_data <- hive_data %>%
    select(!dt)
  
  return(hive_data)
  
}
