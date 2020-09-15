# Working with outliers. Snakke med Frederik om Threshold værdi

# TODO:
# - Get raw last year midnight data
# - Define Threshold. Ask Frederik??
# - Delete outliers by using some kind of Threshold
# - Compare with NASA data from HiveTool

setwd("/home/arm/Documents/softwaretechnology/bigdata/r_scripts/bistader") # From DELL


# Import data from csv
hive_data <- read.table(file="data/FHA_Stade1_without_header", sep=",")
hive_data <- hive_data[ c("V1","V2")] # Extract only timestamp and weight 
hive_data <- na.omit(hive_data)
colnames(hive_data) <- c("timestamp", "hive_weight")
hive_data$timestamp <- as.Date(hive_data$timestamp)
plot(hive_data$timestamp, hive_data$hive_weight, type = 'l', xlab="date" , ylab="weight")

# Import from sqlite

# TODO 
# - delete noise (manual indgreb, regn, mere ??)
# - udligne graf ved at tage en dag gennesnit. 



# hvordan kan jeg automatisere at der var mellemrum i timestamp så slette den store jump

install.packages("zoo")
?zoo::zoo
# https://stat.ethz.ch/pipermail/r-help/2010-October/257749.html



# sudo apt-get -y install sudo apt install build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev
install.packages("devtools", dependencies = TRUE)
?install.packages
library(devtools)
devtools::install_github("robjhyndman/anomalous-acm")
library(anomalousACM)
z <- ts(matrix(rnorm(3000),ncol=100),freq=4)
y <- tsmeasures(z)
biplot.features(y)
anomaly(y)


# Outliers
install.packages("forecast")
library(forecast)
?tsoutliers
tsoutliers(timeseries)
plot(timeseries)
boxplot.stats(hive_data$delta)$stats # returns the extreme of the lower whisker, the lower ‘hinge’ (The lower hinge is the 25th precentile), the median, the upper ‘hinge’ and the extreme of the upper whisker.
outlier() # https://www.rdocumentation.org/packages/schoRsch/versions/1.7/topics/outlier 




