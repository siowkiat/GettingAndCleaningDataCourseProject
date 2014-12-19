## R script which analyses the input data set and produces a tidy output data set

## To use this script:
## 1. copy the "UCI HAR Dataset" folder to the folder where this script resides.
## 2. set the RStudio working directory to the folder where this script resides.
## 3. load this script into RStudio
## 4. run the function "runAnalysis()", which returns the tidy data as a data frame
##    > tidy <- runAnalysis()

## mergeDataSets() combines the "test" and "train" data files into a list of 3 
## data frames
mergeDataSets <- function(dir, subDirs) 
{
    ## form the full path to the "dir" folder
    dataRoot <- paste(getwd(), dir, sep = "/")
    
    for (i in seq_along(subDirs))
    {
        ## form the full path to each "subDirs[i]" folder
        dataSubDir <- paste(dataRoot, subDirs[i], "", sep = "/")
        
        ## form the full paths to the 3 files in each subDirs[i] folder
        dataFileX <- paste(dataSubDir, "X_", subDirs[i], ".txt", sep = "");
        dataFileY <- paste(dataSubDir, "y_", subDirs[i], ".txt", sep = "");
        dataFileSubjects <- paste(dataSubDir, "subject_", subDirs[i], ".txt", sep = "");
        
        if (i == 1)
        {
            ## for the first subDirs[i], initialize the 3 output data frames
            ## by reading directly from the 3 data files
            totalX <- read.table(dataFileX)
            totalY <- read.table(dataFileY)
            totalSubjects <- read.table(dataFileSubjects)
        }
        else
        {
            ## for the second subDirs[i], read each file into a temporary
            ## data frame, then row-binds it to the output data frame
            x <- read.table(dataFileX)
            totalX <- rbind(totalX, x)
            
            y <- read.table(dataFileY)
            totalY <- rbind(totalY, y)
            
            subjects <- read.table(dataFileSubjects)
            totalSubjects <- rbind(totalSubjects, subjects)
        }
    }
    
    # return a list of the combined data
    list(totalX, totalY, totalSubjects)
}

## getMeanAndStdFeatures() reads "features.txt" and extracts those names which
## have "-mean()"" and "-std()" strings
getMeanAndStdFeatures <- function(dir) 
{
    ## form the full path to the "dir" folder
    dataRoot <- paste(getwd(), dir, sep = "/")
    
    ## form the full path to the feature.txt file
    featureFile <- paste(dataRoot, "features.txt", sep = "/");
    
    ## read the names of all features
    allNames <- read.table(featureFile, stringsAsFactors=FALSE)
    
    ## keep only those names which include the strings
    ## -mean() and -std()
    keepNames <- grep("-mean\\(\\)|-std\\(\\)", allNames[,2])
    
    ## return only those rows with feature names that have
    ## "-mean()" and "-std()" strings
    allNames[keepNames,]
}

## getActivityNames() reads "activity_labels.txt"
getActivityNames <- function(dir) 
{
    ## form the full path to the "dir" folder
    dataRoot <- paste(getwd(), dir, sep = "/")
    
    ## form the full path to the activity_labels.txt file
    activityFile <- paste(dataRoot, "activity_labels.txt", sep = "/");
    
    ## read the names of all activities
    allNames <- read.table(activityFile, stringsAsFactors=FALSE)
    
    ## return only column 2 of the data frame
    allNames[,2]
}

## makeTidyDataSet() computes averages of variables and creates the tidy data set
makeTidyDataSet <- function(srcDataSet)
{
    ## get the unique activities and subjects
    activities <- levels(srcDataSet$activity)
    subjects <- unique(srcDataSet$subject)
    
    ## get the last column index of the input data set
    lastColumn <- ncol(srcDataSet)
    
    tidy <- data.frame()
    
    for (i in seq_along(subjects))
    {
        for (j in seq_along(activities))
        {
            ## subset the data frame by each "subject" and "activity"
            subjectActivity <- srcDataSet[srcDataSet$subject==subjects[i] & 
                                          srcDataSet$activity==activities[j],]
            
            ## column 1 is the subject (integer index)
            ## column 2 is the activity (descriptive name)
            ## compute the means of column 3 to last column
            subjectActivity.mean <- colMeans(subjectActivity[,3:lastColumn])
            
            ## assemble column 1, 2 and the column-means into a list
            tidy.row <- append(list(subjects[i], activities[j]), subjectActivity.mean)
            
            ## give the first 2 list items proper names, so that they can be 
            ## rbind() to form the "tidy" data frame.
            names(tidy.row)[1:2] <- c("subject", "activity")
            tidy <- rbind(tidy, data.frame(tidy.row, stringsAsFactors=TRUE, 
                                           check.names = FALSE))
        }
    }
    
    ## add the prefix "average." to the the column names of "newDataSet" and 
    ## apply the new names to the "tidy" data frame.
    newColNames <- paste("average.", colnames(tidy)[3:lastColumn], sep="")
    colnames(tidy)[3:lastColumn] <- newColNames
    
    ## return the tidy data frame
    tidy
}

## runAnalysis() is the entry point of this script.  It performs the data tidying 
## operation in 5 steps.
runAnalysis <- function() 
{
    ## Step 1. Merges the training and the test sets to create one data set.
    
    ## 'dir' is the input data set folder
    ## `subDirs` are sub-folders in `dir` containing the training and test 
    ## data sets
    dir = "UCI HAR Dataset"
    subDirs = c("train", "test")
    
    ## calls mergeDataSets() to perform the merging of training and test data
    merged <- mergeDataSets(dir, subDirs)
    
    totalX <- data.frame(merged[1])
    totalY <- data.frame(merged[2])
    totalSubjects <- data.frame(merged[3])

    
    ## Step 2. Extracts only the measurements on the mean and standard deviation
    ##         for each measurement. 
    
    ## calls getMeanAndStdFeatures() to return only those rows with feature names
    ## that have "-mean()" and "-std()" strings
    featNames <- getMeanAndStdFeatures(dir)
    
    ## form a vector of feature column names to retain, like "V1", "V2" etc
    vColNames <- paste("V",featNames[,1],sep="")
    
    ## filter totalX such that only those columns that match vColNames remain
    keepX <- totalX[,names(totalX) %in% vColNames]
    
    
    ## Step 3. Uses descriptive activity names to name the activities in the 
    ##         data set

    ## calls getActivityNames() to read descriptive activities names
    actNames <- getActivityNames(dir)
    
    ## replace activity with descriptive names
    totalActivities <- data.frame(actNames[totalY[,1]], stringsAsFactors=TRUE)
    
    
    ## Step 4. Appropriately labels the data set with descriptive variable names
    
    ## give the remaining columns valid names by removing brackets(),
    ## replacing dash - with dot .
    colnames(keepX) <- gsub("\\(\\)", "", gsub("-", ".", featNames[,2]))
    colnames(totalSubjects)<- c("subject")
    colnames(totalActivities)<- c("activity")
    # form a new data.frame using the columns
    newDataSet <- cbind(totalSubjects,totalActivities,keepX)
    
    
    ## Step 5. From the data set in step 4, creates a second, independent tidy  
    ##         data set with the average of each variable for each activity and
    ##         each subject.
    tidyDataSet <- makeTidyDataSet(newDataSet)

    ## returns the tidy data set to the caller
    tidyDataSet
}
