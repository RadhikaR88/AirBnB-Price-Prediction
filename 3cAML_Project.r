print("Algorithmic Machine Learning Project: AirBnB (New York Data Set)")
print("Submitted by Radhika Rajeevan and Sunit Nair")
print("")

print("Installing required packages")
#install.packages("RMySQL")
#install.packages("MASS")
#install.packages("tidyverse")
#install.packages("glmnet")
#install.packages("tree")
#install.packages("xgboost")
#install.packages("caret")

library(RMySQL)
library(MASS)
library(tidyverse)
library(glmnet)
library(tree)
library(xgboost)
library(caret)

print("NOTE: The data set is available as a cleaned CSV file and was loaded into MySQL database for this project")
readline("Press Enter to continue")
read_from <- readline("Enter 1 to read from database and 0 to read from CSV: ")

r_user <- "r_user"
r_password <- "r_password"
log_regression <- FALSE

read_log <- readline("Enter 1 to run regression models against log(price) instead of price: ")
if(as.integer(read_log)==1){
  log_regression <- TRUE
} else {
  log_regression <- FALSE
}

db_name <- "aml"
if(as.integer(read_from)==1){
  print(paste("Connecting to database with user",r_user))
  mydb <- dbConnect(MySQL(), user=r_user, password=r_password, dbname=db_name, host="localhost")
  print(paste("Showing list of tables available in schema",db_name))
  tableNames <- dbListTables(mydb)
  print(tableNames)
  print(paste("Checking columns in table",tableNames[1]))
  colNames <- dbListFields(mydb, tableNames[1])
  print(colNames)
  print(paste("Fetching all data from ",tableNames[1]))
  tableQuery <- paste("SELECT * FROM ",db_name,".",tableNames[1],sep="")
  resultSet <- dbSendQuery(mydb, tableQuery)
  airData <- fetch(resultSet,n=-1)
  dbDisconnect(mydb)
} else {
  if(as.integer(read_from)==0){
    print("Reading from CSV")
  } else{
    print("Invalid input, defaulting to reading from CSV")
  }
  airData <- read.csv("final_project.csv")
}

print("Dimensions of airData:")
print(dim(airData))
readline("Press Enter to continue")

print("Converting boolean columns to integers")
airData[,31:130] <- lapply(airData[,31:130],as.integer)

print("Deriving new features from data set")
print("Deriving number of features as numerical feature")
airData$featureCount <- apply(airData[,31:130],1,sum)
print("Deriving yearAsHost as numerical feature")
airData$yearsAsHost <- (2019 - airData$hostYear)

print("Converting categorical columns to factors")
airData[,31:130] <- lapply(airData[,31:130],as.factor)
airData$neighbourhoodCleansed <- as.factor(airData$neighbourhoodCleansed)
airData$neighbourhoodGroupCleansed <- as.factor(airData$neighbourhoodGroupCleansed)
airData$bedType <- as.factor(airData$bedType)
airData$cancellationPolicy <- as.factor(airData$cancellationPolicy)
airData$propertyType <- as.factor(airData$propertyType)
airData$roomType <- as.factor(airData$roomType)
airData <- as.data.frame(airData)

print("Summary of airData:")
print(summary(airData))

print("Dropping columns from airData that have been used to derive other columns, have repeated information, or have low count for certain levels")
dropColumns <- c("id","hostYear","accessibleHeightToilet","BBQgrill","babyBath","babyMonitor","babySitterRecommendations","bathTub","bedLinens","breakfast","changingTable","cats","childrenBooksAndToys","childrenDinnerware","cleaningBeforeCheckout","coffeemaker","cookingBasics","crib","dishesAndSilverware","dishwasher","dogs","doormanEntry","extraPillowsBlankets","fireplaceGuards","freeParkingOnStreet","gameConsole","gardenOrBackyard","railsInShowerToilet","highchair","hotwater","indoorFireplace","keypad","lockbox","longTermStaysAllowed","luggageDropOffAllowed","microwave","otherPets","outletCovers","oven","packNPlayTravelCrib","pathToEntranceLitAtNight","patioOrBalcony","privateBathroom","privatEentrance","privateLivingRoom","refrigerator","shades","safetyCard","smartlock","stairGates","stepFreeaccess","stove","suitableForEvents","tableCornerGuards","washerDryer","wideClearanceToBed","wideClearanceShowerToilet","wideDoorway","wideHallwayClearance","windowGuards","hosting_amenity_49","hosting_amenity_50")
airDataClean <- airData[,!(names(airData) %in% dropColumns)]
airDataClean <- as.data.frame(airDataClean)

print("Columns in cleaned airData set")
print(names(airDataClean))

print("Clubbing infrequent neighborhoods into 'Other' category")
neighborhoodList <- unique(airDataClean$neighbourhoodCleansed)

print("Converting column as character to replace with Other")
airDataClean$neighbourhoodCleansed <- as.character(airDataClean$neighbourhoodCleansed)
print("Neighborhood summary before cleansing")
print(summary(airDataClean$neighbourhoodCleansed))

print("Clubbing infrequent neighborhoods into 'Other'")
for(n in neighborhoodList)
{
  tempList <- airDataClean$neighbourhoodCleansed == n
  rcount <- length(which(tempList))
  print(paste(n,":",rcount))
  if(rcount <= 300){
    print(paste("Changing ",n," to Other"))
    airDataClean$neighbourhoodCleansed[tempList] <- "Other"
  }
}

print("Converting neighborhood as factor post-clubbing")
airDataClean$neighbourhoodCleansed <- as.factor(airDataClean$neighbourhoodCleansed)

print("Summary of neighborhood column post clubbing")
print(summary(airDataClean$neighbourhoodCleansed))
readline("Press Enter to continue")

print("Extract data without price as predict data set")
airDataPredict <- airDataClean[airDataClean$price == 0,]
print(paste("Number of rows in airDataPredict:",nrow(airDataPredict)))

print("Extract valid data with price as actual data set")
airDataValid <- airDataClean[airDataClean$price > 0,]
print(paste("Number of rows in airDataValid:",nrow(airDataValid)))

if(log_regression){
  airDataValid$price <- log(airDataValid$price)
}

print("Creating sample training set and test sets")
train <- sample(1:nrow(airDataValid),0.95*nrow(airDataValid))
airDataTrain <- airDataValid[train,]
airDataTest <- airDataValid[-train,]
readline("Press Enter to continue")

print("Running Linear Regression Model: Price vs Everything")
readline("Press Enter to continue")
lm1 <- lm(price~.,data=airDataTrain)
print("Summary of Linear Regression")
print(summary(lm1))
print("Using Linear Regression Model for prediction")
print("WARNING!!!: This step may fail in case the training set and test set have different levels. If this occurs, re-running the code usually fixes it.")
lm1Pred <- predict(lm1, airDataTest)
print(paste("Test MSE:",mean((airDataTest$price - lm1Pred) ^ 2)))

readline("Press Enter to continue")

print("Running PCA on numerical features")
readline("Press Enter to continue")
pcaDF <- data.frame(cbind(hostResponseHours=airDataValid$hostResponseHours,accommodates=airDataValid$accommodates,bathrooms=airDataValid$bathrooms,bedrooms=airDataValid$bedrooms,beds=airDataValid$beds,TV=airDataValid$TV,cleaningFee=airDataValid$cleaningFee,extraPeople=airDataValid$extraPeople,guestsIncluded=airDataValid$guestsIncluded,maximumNights=airDataValid$maximumNights,minimumNights=airDataValid$minimumNights,price=airDataValid$price,securityDeposit=airDataValid$securityDeposit,numberOfReviews=airDataValid$numberOfReviews,reviewScoresAccuracy=airDataValid$reviewScoresAccuracy,reviewScoresCheckin=airDataValid$reviewScoresCheckin,reviewScoresCleanliness=airDataValid$reviewScoresCleanliness,reviewScoresCommunication=airDataValid$reviewScoresCommunication,reviewScoresLocation=airDataValid$reviewScoresLocation,reviewScoresLocation=airDataValid$reviewScoresLocation,reviewScoresRating=airDataValid$reviewScoresRating,reviewScoresValue=airDataValid$reviewScoresValue,reviewsperMonth=airDataValid$reviewsperMonth))
pcaModel <- prcomp(pcaDF,scale.=TRUE,center=TRUE)
print("Summary of PCA Model")
print(summary(pcaModel))
print("Rotation Matrix of PCA Model")
print(pcaModel$rotation)

print("PCA Screeplot")
screeplot(pcaModel, main="Variance of PCs")
readline("Press Enter to continue")

print("Plotting Biplot: PC1 vs PC2 (Please wait till plot appears to continue)")
biplot(pcaModel,choices = c(1,2))
readline("Press Enter to continue")
print("Plotting Biplot: PC2 vs PC3 (Commented to reduce runtime)")
#biplot(pcaModel,choices = c(2,3))
readline("Press Enter to continue")
print("Plotting Biplot: PC1 vs PC3 (Commented to reduce runtime)")
#biplot(pcaModel,choices = c(1,3))
readline("Press Enter to continue")

print("Reviews per month and number of reviews have similar factor loadings as do all the individual review columns")
print("Removing Reviews per month, the indiviudal review scores except Review score rating")
readline("Press Enter to continue")
dropColumns <- c("reviewsperMonth","reviewScoresAccuracy","reviewScoresCheckin","reviewScoresCleanliness","reviewScoresCommunication","reviewScoresLocation","reviewScoresValue")
airDataValid <- airDataValid[,!(names(airDataValid) %in% dropColumns)]
airDataValid <- as.data.frame(airDataValid)
print("Summary after deletion of columns")
print(summary(airDataValid))
readline("Press Enter to continue")

print("Retraining linear model with repeated k-fold cross validation")
readline("Press Enter to continue")
train.control <- trainControl(method="repeatedcv",number=10,repeats=3)
lm2 <- train(price~.,data=airDataValid,method="lm",trControl=train.control)
print("Summary of Linear Regression")
print(summary(lm2))
print(lm2)
readline("Press Enter to continue")

print("Removing features with high p-values in cross validated linear model")
readline("Press Enter to continue")
dropColumns <- c("hostResponseHours","neighbourhoodGroupCleansed","bedType","beds","extraPeople","maximumNights","checkIn24Hours","airConditioning","buzzerOrWirelessIntercom","dryer","familyAndKidFriendly","fireExtinguisher","firstAidKit","freeParkingOnPremises","hairdryer","hangers","heating","hottub","internet","iron","kitchen","laptopFriendlyWorkspace","lockOnBedroomDoor","petsLiveOnThisProperty","selfCheckIn","shampoo","smokingAllowed","washer","wirelessInternet","hostHasProfilePic","hostIdentityVerified","instantBookable","isLocationExact","requireGuestPhoneVerification","requireGuestProfilePicture","featureCount","yearsAsHost")
airDataValid <- airDataValid[,!(names(airDataValid) %in% dropColumns)]
airDataValid <- as.data.frame(airDataValid)
print("Summary after deletion of columns")
print(summary(airDataValid))
readline("Press Enter to continue")

print("Retraining linear model with repeated k-fold cross validation")
readline("Press Enter to continue")
train.control <- trainControl(method="repeatedcv",number=10,repeats=3)
lm3 <- train(price~.,data=airDataValid,method="lm",trControl=train.control)
print("Summary of Linear Regression")
print(summary(lm3))
print(lm3)
readline("Press Enter to continue")

print("Creating Regression Tree for prediction")
readline("Press Enter to continue")
airTree <- tree(price~., data=airDataTrain)
print("Plotting Tree")
plot(airTree)
text(airTree,pretty=TRUE)
print("Using Tree Model to predict for Test data")
treePred <- predict(airTree, airDataTest)
print(paste("Test MSE:",mean((airDataTest$price - treePred) ^ 2)))
summary(airTree)
readline("Press Enter to continue")

print("Using Cross Validation to get Pruned Tree")
readline("Press Enter to continue")
cvtree <- cv.tree(airTree,FUN=prune.tree,K=10)
print("Sizes considered:")
print(cvtree$size)
print("Various alphas (k's) considered:")
print(cvtree$k)
print("Corresponding misclassification rates:")
print(cvtree$dev)
print("plot of misclassification rate:")
plot.tree.sequence(cvtree)
print("Extracting best tree from CV model")
bestTree <- prune.tree(airTree, best=cvtree$size[which.min(cvtree$dev)])
print("Plotting best tree")
plot(bestTree)
text(bestTree,pretty=TRUE)
print("Using Best Tree Model to predict for Test data")
readline("Press Enter to continue")
treePred2 <- predict(bestTree, airDataTest)
print(paste("Test MSE:",mean((airDataTest$price - treePred2) ^ 2)))
print(summary(bestTree))
readline("Press Enter to continue")

print("Linear Regression with interaction")
#lmi <- lm(price~(.)^2,data=airDataTrain)
#print(summary(lmi))
#lmiPred <- predict(lmi,airDataTest)
#print(mean((airDataTest$price - lmiPred) ^ 2))
print("Linear Regression with interaction runs prohibitively long (~10 minutes for polynomial degree 2)")
print("The output of the above commented code is pasted below for reference")
print("**************************************************************")
print("Residual standard error: 70.57 on 17072 degrees of freedom")
print("Multiple R-squared:  0.684,	Adjusted R-squared:  0.6635")
print("F-statistic: 33.27 on 1111 and 17072 DF,  p-value: < 2.2e-16")
print("**************************************************************")
print("This indicates that the relationship between price and othe features may be non-linear and/or there may be an interaction effect between certain features.")
readline("Press Enter to continue")

print("Recreating training and test data sets with all columns in cleaned dataSet")
airDataNew <- airDataClean[airDataClean$price > 0,]
if(log_regression){
  airDataNew$price <- log(airDataNew$price)
}
airDataTrain <- airDataNew[train,]
airDataTest <- airDataNew[-train,]
featureSet <- model.matrix(price~.,airDataTrain)[,-1]
responseSet <- airDataTrain$price

print("Running Ridge Regression Model")
readline("Press Enter to continue")
print("Using Cross Validation to determine value of Shrinkage Parameter")
cv <- cv.glmnet(featureSet, responseSet, alpha=0)
minLambda <- cv$lambda.min
print(paste("Min. Lambda determined: ",minLambda))
ridgeModel <- glmnet(featureSet, responseSet, alpha=0, lambda=minLambda)
print(summary(ridgeModel))
print(coef(ridgeModel))
ridgeTest <- model.matrix(price~.,airDataTest)[,-1]
ridgePred <- predict(ridgeModel,ridgeTest)
print(paste("RMSE:",RMSE(ridgePred, airDataTest$price)))
print(paste("R-squared:",R2(ridgePred, airDataTest$price)))
readline("Press Enter to continue")

print("Running Lasso Regression Model")
readline("Press Enter to continue")
print("Using Cross Validation to determine value of Shrinkage Parameter")
cv <- cv.glmnet(featureSet, responseSet, alpha=1)
minLambda <- cv$lambda.min
print(paste("Min. Lambda determined: ",minLambda))
lassoModel <- glmnet(featureSet, responseSet, alpha=1, lambda=minLambda)
print(summary(lassoModel))
print(coef(lassoModel))
lassoTest <- model.matrix(price~.,airDataTest)[,-1]
lassoPred <- predict(lassoModel,lassoTest)
print(paste("RMSE:",RMSE(lassoPred, airDataTest$price)))
print(paste("R-squared:",R2(lassoPred, airDataTest$price)))
readline("Press enter to continue")

print("Using XGBoost")
readline("Press enter to continue")
print("Creating matrices for training and test data for XGBoost")
xgbTestData <- model.matrix(price~.,airDataTest)[,-1]
xgbPredData <- model.matrix(price~.,airDataPredict)[,-1]
xgbTestLabel <- airDataTest$price
print("Setting up XGBoost Training Controls")
xgb_trcontrol = trainControl(method="cv", number=5, allowParallel=TRUE, verboseIter=TRUE, returnData=FALSE)
print("Setting up XGBoost Grid")
xgbGrid <- expand.grid(nrounds=100, max_depth=10, colsample_bytree=0.5, eta=0.1, gamma=0, min_child_weight=50, subsample=0.9)
xgb1 <- train(featureSet, responseSet, trControl=xgb_trcontrol, tuneGrid=xgbGrid, method="xgbTree")
print("Best Tuning Parameters")
print(xgb1$bestTune)
print("Summary of XGBoost model")
print(xgb1)
print("Using XGBoost model to predict on Test Data")
xgbPred <- predict(xgb1,xgbTestData)
print(paste("RMSE:",RMSE(xgbPred, airDataTest$price)))
print(paste("R-squared:",R2(xgbPred, airDataTest$price)))
print("Using XGBoost model to predict on Unknown Data")
xgbPred <- predict(xgb1,xgbPredData)
airDataPredict$price <- xgbPred
print("Printing head and tail for predicted data")
print(head(airDataPredict))
print(tail(airDataPredict))
print("Writing predicted data to file predictedPrices.csv")

if(log_regression){
  airDataPredict$price <- exp(airDataPredict$price)
}

write.csv(airDataPredict,"predictedPrices.csv")
readline("Press Enter to continue")

print("---------- End of Algorithmic Machine Learning Project ----------")