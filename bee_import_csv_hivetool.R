# Import from text file
hive_data <- read.table(file="FHA_Stade1_without_header", sep=",")
hive_data <- hive_data[ c("V2", "V5")] # Extract only weight and temp_out
colnames(hive_data) <- c("hive_weight", "ambient_temperature")
hive_data <- na.omit(hive_data)


