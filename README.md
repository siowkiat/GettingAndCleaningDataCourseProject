## Getting and Cleaning Data Course Project - README

## Overview
The files in this repository implement the Course Project of the "Getting and Cleaning Data" class.  This README describes their contents, how to run the main script, and how the script works.  

The input data set comes from the **"Human Activity Recognition Using Smartphones Dataset"** Version 1.0 by Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, and Luca Oneto, Smartlab - Non Linear Complex Systems Laboratory (www.smartlab.ws).

## Files
* run_analysis.R - R script which analyses the input data set and produces a tidy output data set.
* CodeBook.md - Markdown file which describes the variables in the tidy data set. 
* README.md - This file.

## Prerequisite
The folder containing the input data set **"UCI HAR Dataset"** must be placed together in the same folder as the **"run_analysis.R"** script.  For example:

    > list.files()
    [1] "CodeBook.md"     "README.md"       "run_analysis.R"  "UCI HAR Dataset"

## Usage
In the RStudio console prompt:

    ## set the working directory to the folder where the script resides
    > setwd("c:/git/GettingAndCleaningDataCourseProject")
    ## load the script into RStudio
    > source("c:/git/GettingAndCleaningDataCourseProject/run_analysis.R")
    ## run the function "runAnalysis()", which returns the tidy data as a data frame
    ## it takes under 1 min for the script to finish execution
    > tidy <- runAnalysis()

The **tidy** data frame can be written into a txt file:

    > write.table(tidy, "tidy.txt", row.names=FALSE, col.names=TRUE)

The data can be read from the txt file using this command:

    > tidy <- read.table("tidy.txt", sep=" ", header=TRUE)

## How the R script works
The R script performs the data tidying operation via the **runAnalysis()** main function. This in turn calls 4 helper functions:

    * mergeDataSets() - merges the "test" and "train" data files
    * getMeanAndStdFeatures() - reads "features.txt" and extracts those names which have "-mean()"" and "-std()" strings
    * getActivityNames() - reads "activity_labels.txt"
    * makeTidyDataSet() - computes averages of variables and creates the tidy data set

The execution sequence of **runAnalysis()** is as follows:

    ## 1. Merges the training and the test sets to create one data set.
    It defines variables to store the data folder name "UCI HAR Dataset", as well as sub-folder names "test" and "train".
    
    It calls mergeDataSets(), which returns the combined data of the "test" and "train" files in a list of 3 data frames, namely:
        * totalX - merged using "UCI HAR Dataset/test/X_test.txt" and "UCI HAR Dataset/train/X_train.txt"
        * totalY - merged using "UCI HAR Dataset/test/y_test.txt" and "UCI HAR Dataset/train/y_train.txt"
        * totalSubjects - merged using "UCI HAR Dataset/test/subject_test.txt" and "UCI HAR Dataset/train/subject_train.txt"
    
    ## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
    It calls getMeanAndStdFeatures(), which reads the feature names in "UCI HAR Dataset/features.txt",  and then uses grep() to retain only those features that have "-mean()" and "-std()" in their names. A data frame "featNames" of 2 columns is returned to runAnalysis().
    
    runAnalysis() prefixes "V" to column 1 in featNames so that it forms names like "V1", "V2" etc which can then be used to subset "totalX" from step 1.  This produces the data frame "keepX" containing only those columns with mean and standard deviation measurements.
       
    ## 3. Uses descriptive activity names to name the activities in the data set.
    It calls getActivityNames() which reads "UCI HAR Dataset/activity_labels.txt" and returns a vector of descriptive activity names "actNames".  
    
    runAnalysis() uses "actNames" to convert the integer numbers of "totalY" into descriptive activity names, and produces a new data frame "totalActivities".
    
    ## 4. Appropriately labels the data set with descriptive variable names.
    It replaces the "V1", "V2" etc column names in "keepX" of step 2, with new names derived from "featNames". By applying gsub(), it removes invalid characters such as brackets () and replaces a dash - with a dot .
    
    It also renames the column name of "totalActivities" as "activity, and the column name of "totalSubjects" as "subject". Then it combines "totalSubjects", totalActivities" and "keepX" to form a new data frame "newDataSet".
    
    ## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
   
    It calls makeTidyDataSet() which takes "newDataSet" of step 4, subsets the data frame by each "subject" and "activity", and computes the column means of columns 3 to 68.  This produces a new tidy data set "tidy".  Using the column names of "newDataSet", it adds the prefix "average." and applies the new column names to the "tidy" data frame.
    
    Finally, runAnalysis() returns the tidy data frame to the caller.
    

## Acknowledgment
While writing this README, I have applied tips gathered from reading David Hood's excellent "Project FAQ" post in the class forum. 
https://class.coursera.org/getdata-016/forum/thread?thread_id=50
