source("bee_my_functions.R")

# TODO write a test with two periods
test_manipulate_weight_deltas <- function(){
  hive_data <- import_hive_data(from = "'2020-05-24 00:00:00'", to="'2020-06-01 00:00:00'")
  par(mfrow=c(1,2))
  plot_time_weight(hive_data)
  from <- c("2020-05-28 12:00:01")
  to <- c("2020-05-28 12:40:01")
  desc <- c("Påsat magasin")
  new_delta <- c(0.0)
  periods_to_remove <- data.frame(from, to, new_delta,  desc)
  
  hive_data <- manipulate_weight_deltas(hive_data=hive_data, periods=periods_to_remove)
  
  
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
    mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  if(sum(na.omit( hive_data$weight_delta) > 1)) {
    stop("There are still some wieght delta bigger than one ")
  }
  plot_time_weight(hive_data)
}
test_manipulate_weight_deltas()


test_manipulate_weight_deltas_csv <- function(){
  hive_data <- import_hive_data(from = "'2020-05-01 00:00:00'", to="'2020-09-01 00:00:00'")
  par(mfrow=c(1,2))
  plot_time_weight(hive_data)
  
  

  periods_to_remove <- read.table(file="data/stade1_period_to_ignore_manipulate.csv", sep=",", header = TRUE)
  hive_data <- manipulate_weight_deltas(hive_data=hive_data, periods=periods_to_remove)
  
  
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
    mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  if(sum(na.omit( hive_data$weight_delta) > 1)) {
    stop("There are still some wieght delta bigger than one ")
  }
  plot_time_weight(hive_data)
}
test_manipulate_weight_deltas_csv()
