# Load Packages and Data
library(data.table)
library(reshape2)
library(dplyr)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

# Read activity labels and features
activityLabels <- as_tibble(fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName")))
features <- as_tibble(fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames")))
featuresRequired <- grep("(mean|std)\\(\\)", features$featureNames)

# Read and prepare train set
train <- as_tibble(fread(file.path(path, "UCI HAR Dataset/train/X_train.txt")))
train <- select(train, featuresRequired)
colnames(train) <- features$featureNames[featuresRequired]
colnames(train) <- gsub("[()]", '', colnames(train))
trainActivities <- as_tibble(fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                        , col.names = c("Activity")))
trainSubjects <- as_tibble(fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum")))
train <- as_tibble(cbind(train, trainActivities, trainSubjects))

# Read and prepare test set
test <- as_tibble(fread(file.path(path, "UCI HAR Dataset/test/X_test.txt")))
test <- select(test, featuresRequired)
colnames(test) <- features$featureNames[featuresRequired]
colnames(test) <- gsub("[()]", '', colnames(test))
testActivities <- as_tibble(fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                                   , col.names = c("Activity")))
testSubjects <- as_tibble(fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                                 , col.names = c("SubjectNum")))
test <- as_tibble(cbind(test, testActivities, testSubjects))

# Merge train and test sets
merged$Activity <- factor(merged$Activity, levels = activityLabels$classLabels,
                          labels = activityLabels$activityName)

# create a tidy data set with the average of each variable for each activity and each subject
merged$SubjectNum <- as.factor(merged$SubjectNum)
merged <- melt(data = merged, id = c("SubjectNum", "Activity"))
merged <- dcast(merged, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# Write final data to a file
fwrite(x = merged, file = "tidy-data.txt", quote = FALSE)