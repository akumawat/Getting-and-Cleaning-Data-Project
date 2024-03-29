## Author 			: 			Anurag Kumawat
##Date 				: 			April 27,2014

# Merge the Training and the TEst Data sets to create one data set

getMergedData <- function(trainFilename, testFileName) {
  
  # This function return the merged training and test data
  # by reading data from the input files
  #
  # Args:
  #   trainFilename: the input matrix whose inverse needs to be cached
  #   testFileName: file containing the test data
  # Returns:
  #   merged data from training and test data files
  
  trainingData <- read.table(paste("train/", trainFilename, sep=""))
  testData <- read.table(paste("test/", testFileName, sep=""))
  # return the merged data using row bind function
  
  rbind(trainingData, testData)
}

#read the measurements in X_<training/test>.txt file

measurementData <- getMergedData("X_train.txt","X_test.txt")

#read the subject data from the file subject_<training/test>.txt file

subjectData <- getMergedData("subject_train.txt","subject_test.txt")

#read the activity data from the file activity_<training/test>.txt file

activityData  <- getMergedData("y_train.txt","y_test.txt")

# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 

featureColumns <- read.table("features.txt",header = FALSE,as.is = TRUE)


#get the Features as a vector of String 
featureColumnName <- featureData[,2]

names(measurementData) <- featureColumnName
#get the feature vector that has only  mean and standard deviation header

requiredFeatureColumnIndex <- grep(".*mean\\(\\)|.*std\\(\\)", featureColumnName)

#get the subset Of measurment data

measurementSubset <- measurementData[,requiredFeatureColumnIndex]

# Clean the column names by removing the parenthesis
names(measurementSubset) <- gsub("\\(|\\)", "", names(measurementSubset))

# Following the guideline to name column headings in lowercase
names(measurementSubset) <- tolower(names(measurementSubset))


#3. Uses descriptive activity names to name the activities in the data set

actvLabels <- read.table("activity_labels.txt", header=F, as.is=T)
names(actvLabels) <- c("activityID", "activityname")

actvLabels$activityname <- tolower(as.character(actvLabels$activityname))
activityData[, 1] = actvLabels[activityData[, 1], 2]
names(activityData) <- "activity"

# 4. Appropriately label the dataset with descriptive activity names.

names(subjectData) <- "subject"
tidyData <- cbind(subjectData, activityData, measurementSubset)



# 5. Create a tidy data set that has the average of each variable for each activity and each subject.

uniqueSubjects = unique(subjectData)[,1]
nSubjects = length(unique(subjectData)[,1])
nActivities = length(actvLabels[,1])
nCols = dim(tidyData)[2]
tidyDataFinal = tidyData[1:(nSubjects * nActivities), ]

resultRecord = 1
for (subject in 1:nSubjects) {
  for (activity in 1:nActivities) {
    tidyDataFinal[resultRecord, 1] = uniqueSubjects[subject]
    tidyDataFinal[resultRecord, 2] = actvLabels[activity, 2]
    temp <- tidyData[tidyData$subject == subject & tidyData$activity == actvLabels[activity, 2], ]
    tidyDataFinal[resultRecord, 3:nCols] <- colMeans(temp[, 3:nCols])
    resultRecord = resultRecord + 1
  }
}

# Finally write the cleaned dataset to a file 
write.table(tidyDataFinal, "tidydataset.txt")
 


