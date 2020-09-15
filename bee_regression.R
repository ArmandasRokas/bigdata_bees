# Linear regression 
fit_hive <- lm(hive_weight ~ ambient_temperature, data=hive_data)
summary(fit_hive)
abline(fit_hive)

# Polynomial regression 
fit_hive_poly <- lm(hive_weight ~ ambient_temperature + I(ambient_temperature^2), data=hive_data)
lines(hive_data$ambient_temperature, fitted(fit_hive_poly))

