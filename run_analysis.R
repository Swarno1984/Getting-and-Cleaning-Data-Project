library(reshape2)

# Set the working Directory and unzip and extract data

setwd('C:/Users/ss45360/Documents/Coursera/UCI/');
filename <- "getdata_dataset.zip"  
  if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, mode ='wb')
  }  
  if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
  }

setwd('C:/Users/ss45360/Documents/Coursera/UCI/UCI HAR Dataset/');

# Read the data directly from the files
features     = read.table('./features.txt',header=FALSE); #imports features.txt
activityType = read.table('./activity_labels.txt',header=FALSE); #imports activity_labels.txt
subjectTrain = read.table('./train/subject_train.txt',header=FALSE); #imports subject_train.txt
subjectTest  = read.table('./test/subject_test.txt',header=FALSE); #imports subject_train.txt
Ytrain       = read.table('./train/y_train.txt',header=FALSE); #imports y_train.txt
Ytest        = read.table("./test/Y_test.txt",header=FALSE) #imports y_test.txt

# Load activity types and features
activityType[,2] <- as.character(activityType[,2])
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
neededfeatures <- grep(".*mean.*|.*std.*", features[,2])
neededfeatures.names <- features[neededfeatures,2]
neededfeatures.names = gsub('-mean', 'Mean', neededfeatures.names)
neededfeatures.names = gsub('-std', 'Std', neededfeatures.names)
neededfeatures.names <- gsub('[-()]', '', neededfeatures.names)


# Load the Train and Test datasets
Xtrain <- read.table('./train/x_train.txt')[neededfeatures]
Xtrain <- cbind(subjectTrain, Ytrain, Xtrain)
  
Xtest <- read.table("./test/X_test.txt")[neededfeatures]
Xtest <- cbind(subjectTest, Ytest, Xtest)

# merge both the datasets add labels
mergedData <- rbind(Xtrain, Xtest)
colnames(mergedData) <- c("subject", "activity", neededfeatures.names)

# Convert the activities and labels into factors
mergedData$activity <- factor(mergedData$activity, levels = activityType[,1], labels = activityType[,2])
mergedData$subject <- as.factor(mergedData$subject)

mergedData.melted <- melt(mergedData, id = c("subject", "activity"))
mergedData.mean <- dcast(mergedData.melted, subject + activity ~ variable, mean)

write.table(mergedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)