source("bee_my_functions.R")

# TODO write a test with two periods
test_manipulate_weight_deltas <- function(){
  hive_data <- import_hive_data(from = "'2020-05-24 00:00:00'", to="'2020-06-01 00:00:00'")
  par(mfrow=c(1,2))
  plot_time_weight(hive_data)
  from_timestamps <- c("2020-05-28 12:00:01")
  to_timestamps <- c("2020-05-28 12:40:01")
  desc <- c("Påsat magasin")
  new_deltas <- c(0.0)
  periods_to_remove <- data.frame(from_timestamps, to_timestamps, desc, new_deltas)
  
  hive_data <- manipulate_weight_deltas(hive_data=hive_data, periods=periods_to_remove)
  
  
  hive_data <- hive_data %>%  mutate(weight_delta = hive_weight_kgs - dplyr::lag(hive_weight_kgs)) %>%
    mutate(weight_delta = ifelse(is.na(weight_delta), 0, weight_delta))
  
  if(sum(na.omit( hive_data$weight_delta) > 1)) {
    stop("There are still some wieght delta bigger than one ")
  }
  plot_time_weight(hive_data)
}
test_manipulate_weight_deltas()
