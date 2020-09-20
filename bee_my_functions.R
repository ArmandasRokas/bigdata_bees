import_hive_data <- function(from, to){
  library(DBI)
  con <- dbConnect(RSQLite::SQLite(), "data/stade1.db")
  table_name <- dbListTables(con)
  fields <- dbListFields(con, table_name)
  select_period_with_intervention_query <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > ",from," AND 
                        hive_observation_time_local < ", to, sep=" ") 
  
  sendQuery <- dbSendQuery(con, select_period_with_intervention_query )
  #  hive_data <<- dbFetch(sendQuery) 
  hive_data <- dbFetch(sendQuery) 
  hive_data$hive_observation_time_local <- strptime(hive_data$hive_observation_time_local, format = "%Y-%m-%d %H:%M:%S") #  Convert string to be recognized as date
  return (hive_data)  
}

import_hive_data_csv <- function(filename){
  hive_data <- read.table(file=filename, sep=",")
  hive_data <- hive_data[ c("V1", "V2")] 
  colnames(hive_data) <- c("hive_observation_time_local", "hive_weight_kgs")
  hive_data$hive_observation_time_local <- strptime(hive_data$hive_observation_time_local, format = "%Y-%m-%d %H:%M:%S") #  Convert string to be recognized as date
  return (hive_data)  
}

extract_rows_given_weightdelta <- function(hive_data, weightdelta){
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs -
                                       dplyr::lag(hive_weight_kgs)) %>%
    mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  hive_data[which(abs(hive_data[,"weight_delta"]) > weightdelta), 
            c("hive_observation_time_local", "weight_delta")]
}

extract_rows_given_timedelta <- function(hive_data, timedelta){
  hive_data <- hive_data %>%  mutate(timestamp_delta = hive_observation_time_local -
                                       dplyr::lag(hive_observation_time_local)) %>% 
    mutate(timestamp_delta = ifelse(is.na(timestamp_delta), 0, timestamp_delta))
  hive_data[which(abs(hive_data[,"timestamp_delta"]) > timedelta), 
            c("hive_observation_time_local", "timestamp_delta")]
}

plot_time_weight <- function(hive_data, title){
  if(missing(title)){
    title <- "Vægtudvikling"
  }
  min <- as.Date(head(hive_data, 1)[,"hive_observation_time_local"])
  max <- as.Date(tail(hive_data, 1)[,"hive_observation_time_local"])   
  plot(hive_data$hive_observation_time_local, hive_data$hive_weight_kgs, type = 'l', xlab = paste("Tid fra", min, "til", max, sep= " ") , ylab="Vægt", main=title)
  # , at=seq(as.Date(min),as.Date(max),by=(13*7))
}

plot_time_weight_temp <- function(hive_data){
  min <- as.Date(head(hive_data, 1)[,4])
  max <- as.Date(tail(hive_data, 1)[,4])
  par(mar = c(5, 5, 3, 5))
  plot(hive_data$hive_observation_time_local, hive_data$hive_weight_kgs, type ="l", ylab = "Vægt",
       main ="Sammenhæng mellem vægt og temperatur", xlab = paste("Tid fra", min, "til", max, sep= " "),
       col = "blue")
  par(new = TRUE)
  plot(hive_data$hive_observation_time_local, hive_data$ambient_temp_c, type = "l", xaxt = "n", yaxt = "n",
       ylab = "", xlab = "", col = "red") # , lty = 2
  axis(side = 4)
  mtext("Temperatur", side = 4, line = 3)
  legend("topleft", c("Vægt", "Temperatur"),
         col = c("blue", "red"), lty = c(1, 1))
}


manipulate_weight_deltas <- function(hive_data, periods){
  library(dplyr)
  # Add column weight_delta
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  # Manipulate weight deltas
  for(row in 1:nrow(periods)){
    hive_data$weight_delta[hive_data$hive_observation_time_local> periods[row, "from"]  & hive_data$hive_observation_time_local < periods[row, "to"]  ] <- periods[row, "new_delta"]
  }
  
  # Produce cumulative sums of weight deltas
  hive_data <- hive_data %>% mutate(cum_delta=cumsum(weight_delta))
  
  # Produce new hive_weight_kgs from calculated cumukatiuve sums
  hive_data <- hive_data %>% mutate(hive_weight_kgs = hive_weight_kgs[1]+ cum_delta)
  
  
  # Remove the produced columns
  drops <- c("weight_delta", "cum_delta")
  hive_data <- hive_data[ , !(names(hive_data) %in% drops)]
  return(hive_data)
}

extract_midnight_weights <- function(hive_data){
  
  hive_data <- hive_data %>% 
  mutate( dt = as.Date(hive_observation_time_local)) %>% 
  group_by(dt) %>%
  filter(hive_observation_time_local == min(hive_observation_time_local)) %>%
  ungroup() %>%
  select(!dt)
  
  return(data.frame(hive_data))
  
}

return_period <- function(hive_data, from ,to){
  from <-  strptime(from, format = "%Y-%m-%d %H:%M:%S")
  to <- strptime(to, format = "%Y-%m-%d %H:%M:%S")
  return(hive_data[hive_data$hive_observation_time_local > from & hive_data$hive_observation_time_local < to  , ])
}

