# Import
library(DBI)
setwd("/home/arm/Projects/bigdata/r_scripts/bistader")
con <- dbConnect(RSQLite::SQLite(), "data/stade1.db")
table_name <- dbListTables(con)
fields <- dbListFields(con, table_name)
selectAllQuery <- paste("SELECT * from", table_name, "WHERE hive_observation_time_local > '2018-05-01 00:00:00'", sep=" ")
sendQuery <- dbSendQuery(con, selectAllQuery )
hive_data <- dbFetch(sendQuery)

# Timeseries
weights <- hive_data[,"hive_weight_kgs"] # Extract only weight

weights_timeseries <- ts(weights, start=c(2018,186416/5 ), frequency = 60*24*365.25/5)  # The cycle is annual with frequency 5 minutes. Start 11 o clock. https://www.timeanddate.com/date/timeduration.html
plot(weights_timeseries)
 ## Problem her er at der er jo missing values. ts() har jo ingen mulighed til at vide om det. 
## IT does not make sense with dato in timeseries, fix start dato

# We need to decomppise because if we can to predict, we need to know how much to add in this particual season. 
# It could make maybe more sense in daily data. Where bees leave in the mornings and come back in the evenings. 
# TODO import daily data
# How to define daily cycles


