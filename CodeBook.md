# Dependencies
* stringr library
  - For gsub()
* tidyr library
  - For gather()
* dplyr library
  - For `%>%`, `mutate`, `merge`, `select`, `filter`, `group_by`, etc.

# The Variables
* _featuresTmp_ reads `features.txt`
  - Has a list of the different features and an ID for each.
* _features_ has the cleaned features.
  - data.frame with columns "Id" and "Name"
* _meanAndStdIndexes_ The indexes of mean and standard deviation fields that are of interest.
* _trainSet_ Reads `train/X_train.txt`
  - `X_train.txt` has lines with 561 variables in each
* _trainLabels_ Reads `train/y_train.txt`
  - `y_train.txt` has an activity tied to each of the measurements
  - Column is renamed to _activityId_
* _trainSubjects_ Reads `train/subject_train.txt`
  - `train/subject_train.txt` has a subject tied each of the above variable sets.
  - This column is appedend to trainSet
* _testSet_ Reads `test/X_test.txt`
  - `X_test.txt` has one line with 561 variables
* _testLabels_ Reads `test/y_test.txt`
  - `y_test.txt` has an activity tied to each of the above variable sets.
  - Column is renamed to _activityId_
* _testSubjects_ Reads `test/subject_test.txt`
  - `test/subject_test.txt` has a subject tied each of the measurements
  - This column is appedend to testSet
* _activityLabels_ Reads `activity_labels.txt`
  - `activity_labels.txt` has the activity definitions
  - Columns are renamed to "Id","Name"
* _trainActivity_ contains a merge of:
  - trainLabels,activityLabels,by.x="ActivityId",by.y="Id"
  - Name column is appedended to _trainSet_
* _testActivity_ contains a merge of:
  - testLabels,activityLabels,by.x="ActivityId",by.y="Id"
  - Name column is appedended to _testSet_
* _tidyTest_ tidies testSet, uses gather and run these steps:
  - The feature references are the column names, V1..V561, clean-up
  - Fetch the Feature name
  - Only get the features we are interested in, std and mean.
  - Split the sensor to avoid two vars in one column.
  - Mark the source as coming from the Test data set.
  - Do this first for the Test set:
* _tidyTrain_ Same as _tidyTest_
* _mergedSet_ concatenates _tidyTrain_ and _tidyTest_
* _finalAverage_ Groups by and summarizes _mergedSet_
* *NOTE*: There is not enough documentation on how to properly dedup variables on split `features.txt` names

# The data transformations
* For _featuresTemp_:
  - Replace the following characters: `(`,`)`,`-`,`,` with underscores
    - Example: `tBodyAcc-mean()-X` becomes: `tBodyAcc_mean___X`
  - Transform multiple underscores together into a single underscore
    - Example: `tBodyAcc_mean___X` becomes `tBodyAcc_mean_X`
  - Any underscores at the end of the strings are removed.
    - Example: `fBodyBodyGyroJerkMag_meanFreq_` becomes `fBodyBodyGyroJerkMag_meanFreq`
  - Note: There are duplicate headers:
    - Example:
      ```
      311 fBodyAcc-bandsEnergy()-1,16
      325 fBodyAcc-bandsEnergy()-1,16
      339 fBodyAcc-bandsEnergy()-1,16
      ```
  - features starting with _f_ are expanded for clarification to _freq_
    - Example: `fBodyAcc_meanFreq_Z` becomes: `freqBodyAcc_meanFreq_Z`
    - Note: As in the example above, some fiels already have "freq" in its name, it is unclear given the current documentation how to clean this up properly.
  - features starting with _t_ are expanded for clarification to _time_
    - Example: `tBodyAcc_mean_X` becomes: 

# Final variable state
* a `tbl_df` formatted version of _mergedSet_ looks like this:
```
> tbl_df(mergedSet)
Source: local data frame [813,621 x 6]

   Subject      sensor measureType measurement Activity dataset
     (int)       (chr)       (chr)       (dbl)    (chr)   (chr)
1        1 timeBodyAcc      mean_X   0.2885845  WALKING   Train
2        1 timeBodyAcc      mean_X   0.2784188  WALKING   Train
3        1 timeBodyAcc      mean_X   0.2796531  WALKING   Train
4        1 timeBodyAcc      mean_X   0.2791739  WALKING   Train
5        1 timeBodyAcc      mean_X   0.2766288  WALKING   Train
6        1 timeBodyAcc      mean_X   0.2771988  WALKING   Train
7        1 timeBodyAcc      mean_X   0.2794539  WALKING   Train
8        1 timeBodyAcc      mean_X   0.2774325  WALKING   Train
9        1 timeBodyAcc      mean_X   0.2772934  WALKING   Train
10       1 timeBodyAcc      mean_X   0.2805857  WALKING   Train
```
* The _finalAverage_ looks like this:
```
> finalAverage
Source: local data frame [3,160 x 5]
Groups: Subject, Activity, sensor [?]

   Subject Activity          sensor measureType mean(measurement)
     (int)    (chr)           (chr)       (chr)             (dbl)
1        1  WALKING     freqBodyAcc  meanFreq_X       -0.18055871
2        1  WALKING     freqBodyAcc  meanFreq_Y        0.05762916
3        1  WALKING     freqBodyAcc  meanFreq_Z        0.05836928
4        1  WALKING     freqBodyAcc      mean_X       -0.53189516
5        1  WALKING     freqBodyAcc      mean_Y       -0.40643545
6        1  WALKING     freqBodyAcc      mean_Z       -0.59641117
7        1  WALKING     freqBodyAcc       std_X       -0.55306062
8        1  WALKING     freqBodyAcc       std_Y       -0.39015094
9        1  WALKING     freqBodyAcc       std_Z       -0.49858309
10       1  WALKING freqBodyAccJerk  meanFreq_X       -0.04880060
```
