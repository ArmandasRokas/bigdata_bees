import_hive_data <- function(from, to, raw=FALSE, all=FALSE){
  library(DBI)
  con <- dbConnect(RSQLite::SQLite(), "data/stade1.db")
  table_name <- dbListTables(con)
  fields <- dbListFields(con, table_name)
  select_period_with_intervention_query <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > ",from," AND 
                        hive_observation_time_local < ", to, sep=" ") 
  
  sendQuery <- dbSendQuery(con, select_period_with_intervention_query )
  #  hive_data <<- dbFetch(sendQuery) 
  hive_data <- dbFetch(sendQuery) 
  if(!raw){
    hive_data$hive_observation_time_local <- strptime(hive_data$hive_observation_time_local, format = "%Y-%m-%d %H:%M:%S") #  Convert string to be recognized as date
  }
  if(!all){
    vars <- c("hive_observation_time_local", "hive_weight_kgs", "hive_temp_c", "hive_humidity", "ambient_temp_c","ambient_humidity", "ambient_luminance")
    hive_data <- hive_data[vars]
  }
  return (hive_data)  
}


# Function returns hive data with daily values
#, where a daily weight value is a midnight value 
# (answers a question: what was the weight of the end of the given day).
#  Daily tempreture is the highest tempreture of the given day
import_hive_data_daily<- function(from, to){
  to <- substr(to,2,20)
  to <- paste("'", substr(as.POSIXlt(to)-1+60*60*24, 1, 19), "'", sep="") # Change "to date" to import one day after,
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
    select(dt ,ambient_temp_c)
  
  hive_data_temp <- rename(hive_data_temp, ambient_temp_c_day_max = ambient_temp_c )
  
  # Find midnight weight values 
  hive_data <- hive_data %>% 
    mutate( dt = as.Date(hive_observation_time_local)) %>% 
    group_by(dt) %>%
    filter(hive_observation_time_local == min(hive_observation_time_local)) %>%
    ungroup() %>% 
    mutate(hive_weight_kgs = lead(hive_weight_kgs))  %>%   # Move daily weight values one row backwards, so it fits other measurements 
    # because orginally it is the weight from the first measurement after 00:00, but this weight belongs to the date before midnight
    select(!ambient_temp_c) %>%
    slice(1:n()-1)
  
  hive_data <- rename(hive_data, hive_weight_kgs_daily = hive_weight_kgs)
  # Merge midnight weight and max daily temp
  hive_data <- merge(hive_data, hive_data_temp, by="dt")  
  vars <- c("dt", "hive_weight_kgs_daily", "ambient_temp_c_day_max")
  
  return(hive_data[vars])

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
  plot(hive_data$hive_observation_time_local, hive_data$hive_weight_kgs, type = 'l', xlab = paste("Tid fra", min, "til", max, sep= " ") , ylab="Vægt(kg)", main=title)
  # , at=seq(as.Date(min),as.Date(max),by=(13*7))
}

plot_time_weight_temp <- function(hive_data){
  min <- as.Date(head(hive_data, 1)[,"dt"])
  max <- as.Date(tail(hive_data, 1)[,"dt"])   
  par(mar = c(5, 5, 3, 5))
  plot(hive_data$dt, hive_data$hive_weight_kgs_daily, type ="l", ylab = "Vægt(kg)", lty=2,
       main ="Sammenhæng mellem vægt og temperatur", xlab = paste("Tid fra", min, "til", max, sep= " "),
       col = "grey")
  par(new = TRUE)
  plot(hive_data$dt, hive_data$ambient_temp_c_day_max, type = "l", xaxt = "n", yaxt = "n",
       ylab = "", xlab = "", col = "black") # , lty = 2
  axis(side = 4)
  mtext("Temperatur(C)", side = 4, line = 3)
  legend("topleft", c("Vægt", "Temperatur"),
         col = c("grey", "black"), lty = c(2, 1))
}


manipulate_weight_deltas <- function(hive_data, periods){
  library(dplyr)
  # Add column weight_delta
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
  mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  periods$from <- strptime(periods$from, format = "%Y-%m-%d %H:%M:%S")
  periods$to <- strptime(periods$to, format = "%Y-%m-%d %H:%M:%S")
  
  # Manipulate weight deltas
  for(row in 1:nrow(periods)){
    hive_data$weight_delta[hive_data$hive_observation_time_local> periods[row, "from"]  & hive_data$hive_observation_time_local < periods[row, "to"]  ] <- periods[row, "new_delta"]
  }
  
  # Produce cumulative sums of weight deltas
  hive_data <- hive_data %>% mutate(cum_delta=cumsum(weight_delta))
  
  # Produce new hive_weight_kgs from calculated cumulative sums
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

