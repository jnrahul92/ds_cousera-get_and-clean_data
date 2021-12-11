# Get the data from web

rawDataDir <- "./Data"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFileName <- "Data.zip"
rawDataFun <- paste(rawDataDir, "/", rawDataFileName, sep = "")
dataDir <- "./ext_data"

if(!file.exists(rawDataDir)){
    dir.create(rawDataDir)
    download.file(url = rawDataUrl, destfile = rawDataFun)
}

if(!file.exists(dataDir)){
    dir.create(dataDir)
    unzip(zipfile = rawDataFun, exdir = dataDir)
}

#Load data into R environment
#train data
X_train <- read.table(paste(sep="",dataDir, "/UCI HAR Dataset/train/X_train.txt"))
Y_train <- read.table(paste(sep="",dataDir, "/UCI HAR Dataset/train/y_train.txt"))
s_train <- read.table(paste(sep="",dataDir, "/UCI HAR Dataset/train/subject_train.txt"))
#test data
X_test <- read.table(paste(sep="",dataDir, "/UCI HAR Dataset/test/X_test.txt"))
Y_test <- read.table(paste(sep="",dataDir, "/UCI HAR Dataset/test/y_test.txt"))
s_test <- read.table(paste(sep="",dataDir, "/UCI HAR Dataset/test/subject_test.txt"))

#Merge train and test data
X_data <- rbind(X_train,X_test)
Y_data <- rbind(Y_train,Y_test)
S_data <- rbind(s_train,s_test)

# Load feature info
feature <- read.table(paste(sep = "",dataDir,"/UCI HAR Dataset/features.txt"))

# Load activity label
act_label <- read.table(paste(sep = "",dataDir,"/UCI HAR Dataset/activity_labels.txt"))
act_label[,2] <- as.character(act_label[,2])

# Extract feature cols named 'mean' and 'std'
selectedCols <- grep("-(mean|std).*",as.character(feature[,2]))
selectedColNames <- feature[selectedCols,2]
selectedColNames <- gsub("-mean","Mean",selectedColNames)
selectedColNames <- gsub("-std","Std",selectedColNames)
selectedColNames <- gsub("[-()]","",selectedColNames)


# Filter data by cols
X_data <- X_data[selectedCols]
all_data <- cbind(X_data,Y_data,S_data)
colnames(all_data) <- c(selectedColNames,"Activity","Subject")

all_data$Activity <- factor(all_data$Activity,levels = act_label[,1],labels = act_label[,2])
all_data$Subject <- as.factor(all_data$Subject)

# Generate tidy data
library(reshape2)
meltData <- melt(all_data, id.vars = c("Subject","Activity"))
tidyData <- dcast(meltData, Subject+Activity~variable, mean)

# Write the data
write.table(tidyData,"./tidy_dataset.txt",row.names = FALSE,quote = FALSE)