# Setup
install.packages("RSQLite")
library(DBI)

# Connect
getwd()
setwd("/home/arm/Projects/bigdata/r/bistader")
con <- dbConnect(RSQLite::SQLite(), "fha.db")

# Get table name, fields name and distinct ids
table_name <- dbListTables(con)
fields <- dbListFields(con, table_name)
id_field_name <- fields[2]
distinct_ids <- dbFetch(dbSendQuery(con, paste("SELECT DISTINCT" , id_field_name , "FROM ", table_name , sep=" ")))




selectQuery <- paste("SELECT timestamp, hive_weight_kgs from", table_name, "WHERE",id_field_name,  "=3"  , sep=" ")
sendQuery <- dbSendQuery(con, selectQuery )
hive_data <- dbFetch(sendQuery)
hive_data <- na.omit(hive_data)




