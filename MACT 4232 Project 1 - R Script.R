# Installing the necessary packages
if(!require("robustX")) install.packages("robustX")
if(!require("dplyr")) install.packages("dplyr")

# Loading the necessary packages
require(robustX); library(robustbase); library(dplyr)

# Loading the data set
df = read.csv("life_expectancy.csv")

# Viewing the first five rows of the data set
head(df, 5)

# Viewing the dimensions of the data set
dataset_dimensions = dim(df)

cat("Number of Observations/Rows:", dataset_dimensions[1], "\n")
cat("Number of Variables/Columns:", dataset_dimensions[2], "\n")

# Selecting numeric variables for distance calculations and outlier detections
numeric_vars = c("male_bmi", "male_bp", "male_expectancy", "female_bmi", "female_bp", "female_expectancy")
df_numeric = df[, numeric_vars]
head(df_numeric, 5)

summary(df_numeric)

cor(df_numeric)

# ------------------------------ Mahalanobis -------------------------------- #

# Calculating Mahalanobis Distance for Outlier Detection
mahalanobis_distance = sqrt(mahalanobis(df_numeric, colMeans(df_numeric), var(df_numeric)))

my_threshold = sqrt(qchisq(0.95, df = ncol(df_numeric)))

# Identifying the outliers
outliers_by_mahalanobis = which(mahalanobis_distance > my_threshold)

# Index (scatter) Plot of Mahalanobis Distances
plot(mahalanobis_distance, pch = 19, main = "Index Plot of Mahalanobis Distances", 
     xlab = "Observation Index", 
     ylab = "Mahalanobis Distance")

abline(h = my_threshold, col = "red", lty = 2)
points(outliers_by_mahalanobis, mahalanobis_distance[outliers_by_mahalanobis], pch = 4, col = 2, cex = 1.5)

# Total number/count of outliers found by Mahalanobis
cat("Number of Outliers Detected By Mahalanobis:", length(outliers_by_mahalanobis), "\n")

# Print an empty line for legibility reasons
cat("\n")

print("Outlier Indices:")
print(outliers_by_mahalanobis)

identify(1:length(mahalanobis_distance), mahalanobis_distance, labels = 1:length(mahalanobis_distance), cex = 0.8)

# ------------------------------ BACON -------------------------------- #

# Converting the data set to a matrix as it is a requirement for BACON
x = as.matrix(df_numeric)

output = mvBACON(x)

y = cbind(1:nrow(x), output$dis)
colnames(y) = c("Index", "Distance")

# Index (scatter) plot of BACON distances
plot(y, pch = 19, main = "Index Plot of BACON Distances")
abline(h = output$limit, col = "red", lty = 2)
points(y[!output$subset, ], pch = 4, col = 2, cex = 1.5)

# Extracting BACON distances and indices from the 'output' variable
bacon_distance = output$dis
bacon_threshold = output$limit

identify(1:length(bacon_distance), bacon_distance, labels = 1:length(bacon_distance), cex = 0.8)

# Total number/count of outliers found by BACON
outliers_by_bacon = which(!output$subset)
cat("Number of Outliers Detected By BACON:", length(outliers_by_bacon), "\n")

# Print an empty line for legibility reasons
cat("\n")

# Print outlier indices
print("Outlier Indices:")
print(outliers_by_bacon)

# ------------------------------ QQ Plots -------------------------------- #
par(mfrow=c(1,2))  

# Q-Q plot for Squared Mahalanobis Distance vs. quantiles of Chisquare(p)
qqplot(qchisq(ppoints(length(mahalanobis_distance)), df = ncol(df_numeric)), 
       sort(mahalanobis_distance^2), main = "Q-Q Plot of Squared MD",
       xlab = "Chi-Square Quantiles", ylab = "MD")
abline(0, 1, col = "red")

# Q-Q plot for Squared BACON Distance vs. quantiles of Chisquare(p)
qqplot(qchisq(ppoints(length(output$dis)), df = ncol(df_numeric)), 
       sort(output$dis^2), main = "Q-Q Plot of Squared BD",
       xlab = "Chi-Square Quantiles", ylab = "BD")
abline(0, 1, col = "red")