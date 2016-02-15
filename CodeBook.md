# Dependencies
* Stringr library

# The Variables
* _featuresTmp_ reads the features file, unclean.
* _features_ has the cleaned features.
* _meanAndStdIndexes_ The indexes of mean and standard deviation fields that are of interest.
* _trainSet_ The measurements on the training set
* _trainLabels_ The labels for each measurement on the train sets
* _train_ The training data.frame to be merged
  - I create headers such as: `Train.walking.tBodyAcc_mean_X_1` based on each 
* _testSet_ The measurements on the test set
* _testLabels_ The labels for each measurement on the test set
* _test_ The test data.frame to be merged

# The data
# Transformations
* _features_ has the cleaned features.
  - Replace the following characters: `(`,`)`,`-`,`,` with underscores
  - Transform multiple underscores together into a single underscore
  - Note: There are duplicate headers, so I append column number to provide uniqueness.
* I create headers such as: `Train.tBodyAcc_mean_X_1` based on Test and Train for clarity.
 
