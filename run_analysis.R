## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## install the data.table package if necessary
if (!require("data.table")) {
  install.packages("data.table")
}


require("data.table")



## 1. Merges the training and the test sets to create one data set.

# first, Load the activity labels into a vector
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# next, Load the data column names into a vector
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. - 
# Use grep ( grep is awesome ) to subset the features
tidy_features <- grepl("mean|std", features)

# Load and process X_test & y_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# assign the names
names(X_test) = features

# subset to the tidy features
X_test = X_test[,tidy_features]

## 3. Uses descriptive activity names to name the activities in the data set
# Load the activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data using cbind
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.(finally!)
X_train = X_train[,tidy_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# combine the training data sets using cbind
training_data <- cbind(as.data.table(subject_train), y_train, X_train)

## 1. Merges the training and the test sets to create one data set. (!!)
# Merge test and train data using cbind  ( #1 complete!! )
data = rbind(test_data, training_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)

# use melt to melt the dataset with the labels
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
##  apply the mean function to the dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

## write it to a file  write.table() using row.name=FALSE 
write.table(tidy_data, file = "./tidy_data.txt", row.name=FALSE  )
