# We use stringr for word casing convertion.
library(stringr)
library(tidyr)
library(dplyr)
print("- Loading features")
featuresTemp <- read.table("UCI HAR Dataset/features.txt",stringsAsFactors = FALSE)
names(featuresTemp) <- c("Id","Name")
# Note: The features come with chars such as (),-_ some are repeated.
# The repeated values are bandsEnergy() which are disregarded (only mean/std are of interest)
# Variables starting with 'f' are for frequency, their name is clarified
# Variables starting with 't' are for time, their name is clarified
# Double underscores are transformed to single underscore
features <- featuresTemp %>% 
	mutate(Name=gsub("[(),-]","_",Name)) %>%
	mutate(Name=gsub("_{2,}","_",Name)) %>%
	mutate(Name=gsub("_$","",Name)) %>%
	mutate(Name=gsub("^f","freq",Name)) %>%
	mutate(Name=gsub("^t","time",Name))
# Cleanup temp variable:
rm(featuresTemp)
# Gather the column indexes for Mean and Standard Deviation (Step 2)
meanAndStdIndexes <- grep("_([mM]ean|[sS]td)",features$Name)
print("-  Started reading main files into memory")
# X_train.txt has lines with 561 variables in each
trainSet      <- read.table("UCI HAR Dataset/train/X_train.txt")
# y_train.txt has an activity tied to each of the above variable sets.
trainLabels   <- read.table("UCI HAR Dataset/train/y_train.txt")
# train/subject_test.txt has a subject tied each of the above variable sets.
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
# X_test.txt has one line with 561 variables
testSet      <- read.table("UCI HAR Dataset/test/X_test.txt")
# y_test has an activity tied to each of the above variable sets.
testLabels   <- read.table("UCI HAR Dataset/test/y_test.txt")
# test/subject_test.txt has a subject tied each of the above variable sets.
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
# Rename the columns of the activity files for clarity.
print("- Finished reading main files into memory")
names(trainLabels) <- c("ActivityId")
names(testLabels) <- c("ActivityId")
# To find out what each activity Id actually means we need to read the activity definition/labels:
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors=FALSE)
# Rename the activityLabels appropriately
names(activityLabels) <- c("Id","Name")
# Merge activity labels with activity IDs, basically translate the y_<type>.txt activity IDs to real names.
trainActivity <- merge(trainLabels,activityLabels,by.x="ActivityId",by.y="Id")
testActivity  <- merge(testLabels,activityLabels,by.x="ActivityId",by.y="Id")
# Removed unneeded variables
rm(trainLabels)
rm(testLabels)
testSet[,"Activity"] <- testActivity[,"Name"]
trainSet[,"Activity"] <- trainActivity[,"Name"]
testSet[,"Subject"] <- testSubjects
trainSet[,"Subject"] <- trainSubjects
rm(testSubjects)
rm(trainSubjects)
# One variable per column # Each observation different row
# The feature references are the column names, V1..V561, clean-up
# Fetch the Feature name
# Only get the features we are interested in, std and mean.
# Split the sensor to avoid two vars in one column.
# Mark the source as coming from the Test data set.
# Do this first for the Test set:
tidyTest <- gather(testSet,featureId,measurement,-c(Activity,Subject)) %>%
	mutate(featureId=as.numeric(gsub("^V","",featureId))) %>%
	mutate(featureName=features[featureId,"Name"]) %>%
	filter(featureId %in% meanAndStdIndexes) %>%
	separate(featureName,into=c('sensor','measureType'),sep="_",extra="merge") %>%
	mutate(dataset="Test") %>% 
	select(Subject,sensor,measureType,measurement,Activity,dataset)
# Do the same for Train Set:
tidyTrain<- gather(trainSet,featureId,measurement,-c(Activity:Subject)) %>%
	mutate(featureId=as.numeric(gsub("^V","",featureId))) %>%
	mutate(featureName=features[featureId,"Name"]) %>%
	filter(featureId %in% meanAndStdIndexes) %>%
	separate(featureName,into=c('sensor','measureType'),sep="_",extra="merge") %>%
	mutate(dataset="Train") %>%
	select(Subject,sensor,measureType,measurement,Activity,dataset)

mergedSet <- rbind(tidyTrain,tidyTest)
# Remove unused variables:
rm(testSet)
rm(trainSet)
rm(tidyTest)
rm(tidyTrain)
finalAverage <- mergedSet %>% group_by(Subject,Activity,sensor,measureType) %>% summarise(mean(measurement))
finalAverage
