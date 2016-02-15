mergeData <- function(){
	# We use stringr for word casing convertion.
	library(stringr)
	# Read the features file into a temp var.
	featuresTemp <- read.table("UCI HAR Dataset/features.txt",stringsAsFactors = FALSE)
	# The features come with chars such as (),-_ are are repeated.
	# We add the row_number as the last part of the name to provide uniqueness.
	# We also transform double underscore to single underscore.
	features <- gsub("_{2,}","_",paste(gsub("[(),-]","_",featuresTemp$V2),featuresTemp$V1,sep="_"))
	rm(featuresTemp)
	meanAndStdIndexes <- grep("_([mM]ean|[sS]td)_",features)
	activityLabelsTemp <- read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors=FALSE)
	activityLabels <- activityLabelsTemp$V2
	TrainCols   <- c()
	trainSet    <- read.table("UCI HAR Dataset/train/X_train.txt")
	trainLabels <- read.delim("UCI HAR Dataset/train/y_train.txt")[1]
	colNum      <- 1
	for (j in meanAndStdIndexes){
		TrainCols[colNum] <- paste("Train",features[j],sep=".")
		colNum <- colNum + 1
	}
	TrainCols[colNum] <- "Train.Label"
	trainSet$Label <- trainLabels
	train <- data.frame(trainSet[meanAndStdIndexes])
	names(train) <- TrainCols
	TestCols   <- c()
	testSet    <- read.table("UCI HAR Dataset/test/X_test.txt")
	testLabels <- read.delim("UCI HAR Dataset/test/y_test.txt")[1]
	colNum
	for (j in meanAndStdIndexes){
		TestCols[colNum] <- paste("Test",features[j],sep=".")
		colNum <- colNum + 1
	}
	test <- data.frame(testSet[meanAndStdIndexes])
	names(test) <- TestCols
	merge(train,test)
}
