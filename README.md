# Price Prediction for AirBnB Rental listings (New York)

The project aims to analyze the AirBnB data set and intends to predict the price that a new property should expect to charge based on its features like location, capacity of occupancy, number of days to rent etc.

- The data for New York City was extracted and used for the purpose of this project.
- Analysis, filtering, and extraction of categorical variables from the data set was done using Python. 
- The combined, cleansed data file was loaded into a database (MySQL) from where it is read for regression.
- Extraction of derived columns and running the regression models was performed in R and the following methods were used: Linear      Regression, Tree, Ridge/Lasso Regression, and XGBoost. 
- Validation set and k-fold cross validation techniques are used. The output of the predicted prices (for data without prices in data set) is written to a CSV file at the end. 
