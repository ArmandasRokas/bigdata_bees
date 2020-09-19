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

plot_time_weight <- function(hive_data, title){
  if(missing(title)){
    title <- "Vægtudvikling"
  }
  min <- as.Date(head(hive_data, 1)[,4])
  max <- as.Date(tail(hive_data, 1)[,4])
  plot(hive_data$hive_observation_time_local, hive_data$hive_weight_kgs, type = 'l', xlab = paste("Tid fra", min, "til", max, sep= " ") , ylab="Vægt", main=title)
  # , at=seq(as.Date(min),as.Date(max),by=(13*7))
}

plot_time_weight_temp <- function(hive_data){
 # min <- .POSIXct((summary(hive_data$hive_observation_time_local)["Min."])) 
  
  #max <- .POSIXct((summary(hive_data$hive_observation_time_local)["Max."])) 

  # plot(hive_data$hive_observation_time_local, hive_data$hive_weight_kgs, type = 'l',xlab="time", axes=F , ylab="weight", ylim=c(0,60),  main = paste("From", min, "To", max, sep= " "), col="red")
#   lines(hive_data$hive_observation_time_local, hive_data$ambient_temp_c,col="blue")
  ##par(new=TRUE)
  ##plot(hive_data$hive_observation_time_local, hive_data$ambient_temp_c, type = 'l',xlab="time" , ylab="temperature", main = paste("From", min, "To", max, sep= " ",axes=F), col="blue")
#  axis(side=4, at=seq(0,35,by=5), col="blue", col.axis="blue")     # additional y-axis
  #mtext("Temp", side=4, col="blue")

  # , at=seq(as.Date(min),as.Date(max),by=(13*7))
  
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

