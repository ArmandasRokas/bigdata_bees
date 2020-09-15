 
# Automatiseret test, hvor jeg kan smide en hive_data, udfører den tjekker om den har


# Define problem4
setwd("/home/arm/Projects/bigdata/r/bistader")
source("bee_my_functions.R")
hive_data <- import_hive_data(from = "'2020-05-24 00:00:00'", to="'2020-06-01 00:00:00'")
par(mfrow=c(1,2))
plot_time_weight(hive_data)

# 2020-05-28 12:25:01




#weight_deltas <- hive_data$hive_weight_kgs - dplyr::lag(hive_data$hive_weight_kgs)


from_timestamps <- c("2020-05-28 12:00:01")
to_timestamps <- c("2020-05-28 12:40:01")
desc <- c("Påsat magasin")
periods_to_remove <- data.frame(from_timestamps, to_timestamps, desc)


remove_requested_periods(hive_data=hive_data, periods=periods_to_remove)

remove_requested_periods <- function(hive_data, periods){
  library(dplyr)
  # Add column weight_delta
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
    mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
 # from_timestamp <-  strptime("2020-05-28 12:00:01", format = "%Y-%m-%d %H:%M:%S")
 # to_timestamp <- strptime("2020-05-28 12:40:01", format = "%Y-%m-%d %H:%M:%S")
  # en paramter til hvor meget delta skal der være i perioden
 # hive_data$weight_delta[hive_data$hive_observation_time_local> from_timestamp & hive_data$hive_observation_time_local < to_timestamp  ] <- 0.0 # WORKS!
#  hive_data <- hive_data %>% mutate(cum_delta=cumsum(weight_delta))
#  hive_data <- hive_data %>% mutate(hive_weight_kgs = hive_weight_kgs[1]+ cum_delta)
  
  # Stop if there is more than # TODO calculate weight delta again. 
  if(sum(na.omit( hive_data$weight_delta) > 1)) {
    stop("Not all ")
  }

 # Remove calculated column
  return(hive_data)
}



remove_requested_periods <- function(hive_data, periods){
  library(dplyr)
  # Add column weight_delta
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
    mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  from_timestamp <-  strptime("2020-05-28 12:00:01", format = "%Y-%m-%d %H:%M:%S")
  to_timestamp <- strptime("2020-05-28 12:40:01", format = "%Y-%m-%d %H:%M:%S")
  # en paramter til hvor meget delta skal der være i perioden
  hive_data$weight_delta[hive_data$hive_observation_time_local> from_timestamp & hive_data$hive_observation_time_local < to_timestamp  ] <- 0.0 # WORKS!
  hive_data <- hive_data %>% mutate(cum_delta=cumsum(weight_delta))
  hive_data <- hive_data %>% mutate(hive_weight_kgs = hive_weight_kgs[1]+ cum_delta)
  
  sum(na.omit( hive_data$weight_delta) > 1) # Stop if there is more than # TODO calculate weight delta again. 
  stop("Error")
  
  # Remove calculated column
  return(hive_data)
}
  
    #hive_data <- within(
   # hive_data, {
  #    hive_weight_kgs <-hive_weight_kgs + dplyr::lead(weight_delta) #  dplyr::lag(hive_weight_kgs) + weight_delta
  #  }
#  )
 # hive_data$hive_weight_kgs <-hive_data$hive_weight_kgs + dplyr::lead(hive_data$weight_delta) 
  #dplyr::lag(hive_data$hive_weight_kgs )
  
  #hive_data$weight_delta
  
  #tail(hive_data$hive_weight_kgs + dplyr::lead(hive_data$weight_delta) )
  # Add column wieght deltas
  # Change delta to 0, where are in intervals
  # Change weights
  # Remove extra column. 










#hive_data$hive_weight_kgs <- dplyr::lag(hive_data$hive_weight_kgs) + dplyr::lead(hive_data$weight_delta) 

#tail( hive_data$hive_weight_kgs, 1000)


#hive_data$hive_weight_kgs <-32+ hive_data$weight_delta
#hive_data$hive_weight_kgs





#hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
#  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta


# https://stackoverflow.com/questions/36058326/lag-doesnt-see-the-effects-of-mutate-on-previous-rows 
# Try help(Reduce)



# Cumsum

# https://itsalocke.com/blog/understanding-rolling-calculations-in-r/



