# run_analysis.R
#
# Course Project of Module 3 of the Data Science Specialization @ coursera.org
#
# 3 - "Getting Data and Cleaning Data"
#
# Frank M. Berger, github: F-rankie

# this script uses the following libraries:

require(stringr)
require(data.table)
require(dplyr)

# set working directory, check files, set data directory (folder within working directory)
#
setwd("R:/3_GettingData/Project")
getwd()

# set data directory (folder within working directory), check files
#
data.dir <- "UCIdata"
list.files(data.dir)

########## Tasks ##########
#
#  1. Merges the training and the test sets to create one data set.
#  2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#  3. Uses descriptive activity names to name the activities in the data set
#  4. Appropriately labels the data set with descriptive variable names. 
#  5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
###########################


###########  Step 1: Merges the training and the test sets to create one data set.

# set up directories for train and test data, and check existing files

test.dir <- paste0(data.dir, "/test")
test.dir
list.files(test.dir)

train.dir <- paste0(data.dir, "/train")
train.dir
list.files(train.dir)

# main data directory
#
# features.info.txt - explanation of most relevant variables in feature vector
# features.txt - complete list of all 561 features - 561 lines (= 561 features)
# activity_labels.txt - defines 6 different activities (would be a "factor" in R) and how they are coded 1 to 6

######### test.data - 2947 "lines" of measurements in 24 subjects
#
# X_test.txt - 2947 lines, 8976 chars = 561 numeric values per line = one "feature vector" per line
# Y_test.txt - 2947 lines, 1 integer value per line = one "activity label" per line
# subject_test.txt - 2947 lines, 1 integer value per line = subject number

######### train.data - 7352 "lines" of measurements in 30 subjects
#
# X_train.txt - 7352 lines, 8976 columns(single characters) per line = 561 numeric values per line (corresponds to 561 features)
# Y_train.txt - 7352 lines, 1 integer value per line = one "activity label" per line
# subject_train.txt - 7352 lines, 1 integer value per line = subject number

#### subdirectory "Inertial Signals":
#
# files in these two subdirectories will be ignored for now, see FAQ in the coursera forum


# let's first focus on merging the X_test.txt and X_train.txt data in a tidy data set
#
# new data structure would be an array of (2947+7352) = 10299 rows ("observations"), each row containing 561 columns (of class numeric)
# 
# plus the following columns:
# - subject number ("SubjNo"), from subject_xxxx.txt
# - test/train status ("Origin")
# - activity ("Activity"), from Y_xxxx.txt

# prior to reading the actual data, prepare col.names for the feature vector

feat.fn <- "/features.txt"
feat.path.fn <- paste0(data.dir, feat.fn)
DF.feat <- read.table(feat.path.fn, stringsAsFactors=FALSE)
col.names <- DF.feat[,2]

# there should be no doubles in DF.feat[,2]
# but there are!
length(col.names)
length(unique(col.names))       # only 477 instead of 561 - and now?
t <- as.matrix(table(col.names))
NotUnique <- t[t[, 1]>1,]
length(NotUnique)                 # 42 variable names appear 3 times


####### read test data

test.fn <- "/X_test.txt"
test.path.fn <- paste0(test.dir, test.fn)

# tried to use fread() but this crashes RStudio!
# help(fread)
# DT.test <- fread(test.path.fn, header=F, colClasses="numeric", nrows=5L)    # crashes RStudio!

# instead, read test data via read.table() - this is a bit slow ...

DF.test <- read.table(test.path.fn, header=F, colClasses="numeric", col.names=col.names, nrows=-1L) # works

## nrow(DF.test)
## [1] 2947

# prior to merging, add three columns:
# 1 - the subject number
# 2 - the activity
# 3 - the origin (test / train)

# read subject information from subject_test.txt

s_test.fn <- "/subject_test.txt"
s_test.path.fn <- paste0(test.dir, s_test.fn)
s_test.no <- read.table(s_test.path.fn, header=F, colClasses="integer")

# add new column with subject information to DF.test

DF.test$SubjNo <- s_test.no[,1]   

## table(DF.test$SubjNo)           # only 9 (of 24) subjects contribute to the test data
## head(DF.test[,560:562])

# read activity information from Y_test.txt

act_test.fn <- "/Y_test.txt"
act_test.path.fn <- paste0(test.dir, act_test.fn)
act_test.f <- read.table(act_test.path.fn, header=F, colClasses="integer", col.names="f.Activity")
## class(act_test.f[,1])
## [1] "integer"


# generate a new factor to store the Activity
# read from activity_labels.txt

act_lbl.fn <- "/activity_labels.txt"
act_lbl.path.fn <- paste0(data.dir, act_lbl.fn)
DF.act_lbl <- read.table(act_lbl.path.fn, header=F, col.names=c("No", "Label"))
act.f = DF.act_lbl[order(DF.act_lbl$No),]$Label

# act.f <- gl(6, 1,labels=c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LYING"))
# (now replaced by reading from activity_labels.txt)

# add activity as new column to DF.test (as factor)

DF.test$Activity <- act.f[act_test.f$f.Activity]
## table(DF.test$Activity)

# also, add the origin of the data ("test" or "train")
# generate a new factor to store the origin

origin.f <- gl(2,1,labels=c("test", "train"))
DF.test$Origin <- origin.f[1]


############### read and prepare the train data in the same way
#
train.fn <- "/X_train.txt"
train.path.fn <- paste0(train.dir, train.fn)
DF.train <- read.table(train.path.fn, header=F, colClasses="numeric", col.names=col.names, nrows=-1L)
## nrow(DF.train)
## head(DF.train[, 15:20])

# add the subject number as new column (from subject_train.txt)

s_train.fn <- "/subject_train.txt"
s_train.path.fn <- paste0(train.dir, s_train.fn)
s_train.no <- read.table(s_train.path.fn, header=F, colClasses="integer")

DF.train$SubjNo <- s_train.no[,1]
## table(DF.train$SubjNo)           # the other 15 (of 24) subjects, plus 6 new ones (25:30), contribute to the train data

# add activity from Y_train.txt

act_train.fn <- "/Y_train.txt"
act_train.path.fn <- paste0(train.dir, act_train.fn)
act_train.f <- read.table(act_train.path.fn, header=F, colClasses="integer")

## class(act_train.f[,1])
## [1] "integer"

DF.train$Activity <- act.f[act_train.f[,1]]

## between 986 and 1407 datasets per train activity:
## table(DF.train$Activity)

# add Origin

DF.train$Origin <- origin.f[2]

############# merge the two datasets
#
# check if at least the column names are equal
#
if(!identical(names(DF.test), names(DF.train))) { stop("ERROR - different data structures!")}

# not very spectacular - the actual merge - slow with data.frame(s)
# consider to replace with bind_rows() from {dplyr}
#
DF.all <- bind_rows(DF.test, DF.train)

# DF.all now contains the merged dataset - Step 1 finished :) ####################################



##############  Step 2: Extract only the measurements on the mean and standard deviation for each measurement

# create logical vector for all columns, for subsetting later

col.names.l <- vector("logical", ncol(DF.all))      # default = FALSE
scope <- 1:length(col.names)   # 1:561, to avoid "recycling" for the last three columns (562:564)

# check for "mean()" - set the logical vector to TRUE if "mean()" found in variable name (col.names)
col.names.l[scope] <- !is.na(str_locate(col.names, "mean()")[,1])
## length(which(col.names.l, TRUE))
## [1] 46

# same for "std()"
col.names.l[scope] <- col.names.l[scope] | !is.na(str_locate(col.names, "std()")[,1])
## length(which(col.names.l, TRUE))
## [1] 79

# also keep the three new kids on the block ($Activity, $SubjNo and $Origin)
n <- length(col.names.l)
col.names.l[(n-2):n] <- TRUE
## length(which(col.names.l, TRUE))
## [1] 82

col.select <- which(col.names.l, TRUE)

# subsetting:
# keep only the selected 82 columns (46 for mean(), 33 for std(), plus 3 add'l columns, out of the 564)

DF.all.select <- DF.all[, col.select]



############## Step 3: Use descriptive activity names to name the activities in the data set
#
# this is already done via the activity factor
# e.g.:
#
DF.all.select[1:5, c(1, 79:82)]



############## Step 4: Appropriately label the data set with descriptive variable names
#
# already done, by reading "Features.txt" and using it for the variable names (lines 83-89)



############## Step 5: From the data set in step 4, create a second, independent tidy data set
#                      with the average of each variable for each activity and each subject.
#
# this calls for package {dplyr}
#
# I call the class tbl_df "TBL"


# first, make tbl_df out of data.frame
#
TBL.select <- tbl_df(DF.all.select)
## class(TBL.select)

# get rid of $Origin (= last column), will not be used in the "means" tidy data set requested for Step 5

TBL.select <- TBL.select[,-ncol(TBL.select)]
## str(TBL.select[,c(1:3,79:81)])

# generate new table only containing the means

Means.TBL.select <- TBL.select %>% group_by(Activity, SubjNo) %>% summarise_each("mean")
## ncol(Means.TBL.select)
## [1] 81

# slightly modify variable names to differentiate the new means from the original data
#
# e.g. "tBodyAccMag.mean.." -> "m.tBodyAccMag.mean.."

n <- ncol(Means.TBL.select)
Means.TBL.cn <- names(Means.TBL.select)
Means.TBL.cn[3:n] <- paste0("m.", Means.TBL.cn[3:n])
## Means.TBL.cn
names(Means.TBL.select) <- Means.TBL.cn

## names(Means.TBL.select)
## looks good :)

# From the instructions:
# "Please upload your data set as a txt file created with write.table() using row.name=FALSE"

fn <- "fb_tidy.txt"
write.table(Means.TBL.select, file=fn, row.name=FALSE)

## done ;)
