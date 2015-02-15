---
title: "README.md for run_analysis.R"
author: "Frank M. Berger"
date: "Saturday, February 14, 2015"
output: html_document
---

### Introduction

### Directory (folder) structure

My code assumes that the directory structure of the downloaded data zip file is maintained, i.e. the
test and train data are in separate directories (and stay there).

Both test and train directories are subdirectories within the data directory.


### Files in the main data directory

In the main data directory, we find the following files:

* **features.info.txt** - an explanation of the most relevant variables in the feature vector. The feature vector is a set of 561 numeric variables per observation. This corresponds to one line within the X_train and X_test data files (in .txt format).
* **features.txt** - a complete list of all 561 features - 561 lines (= 561 features). This file is used in **run_analysis.R** to assign variable names to the columns of the R data.frame.
* **activity_labels.txt** - this short file defines 6 different activities and how they are coded 1 to 6 (to be coded as "factor" with 6 levels in R) 

### Files in the test and train directories

In each of the two subdirectories, we find the following files:

* **X_test.txt** (or X_train.txt, respectively) - these files contain the main data (i.e. the feature vectors). Both have a width of 8976 characters (letters), corresponding to 561 numeric values per line (each at a fixed width of 16). Whereas the **X_train** data has 7352 lines (corresponding to 7352 observations = approx. 70% of total observations), the **X_test** data has 2947 lines (2947 observations = approx. 30% of total observations).
* **Y_test.txt** (or Y_train.txt, respectively) - these two files contain the same number of lines as the corresponding **X_test**/train files, but only one value (an integer from 1 to 6) per line, which codes for the activity. So this provides the information to which activity the corresponding 561 values from the **X_test**/train file belong.
* **subject_test.txt** (or subject_train.txt, respectively) - very similar to the structure of the **Y_test**/train data, there is only one value per line coding the corresponding subject number (an integer from 1 to 30) to the observations in **X_test**/train. The number of lines is identical to those of **X_test**/train and **Y_test**/train.txt.
* a subdirectory **Inertial Signals**. This can be ignored, these data are not necessary for the project.

### Data structure of the two data frames DF.test and DF.train

In a first step, the test data is read, in a sequence of separate steps, into a data frame, **DF.test**.

The structure of the data frame is as follows:

* 561 columns representing the data from the X files ('feature vector' of 561 numeric variables, as described in **features.txt** *(see above)*)
* one additional column for the activity (1 to 6, taken from the Y file)
* one additional column for the subject number (1 to 30, taken from the subject file)
* one additional column to keep track whether the observation came from the test or the train data (actually not needed for the completion of the assignment)

So the data frame - when completely built - has 564 columns.

In a second step, the train data is read, following exactly the same workflow as for the test data. This creates a 2nd data frame **DF.train**, also containing 564 columns.

### Merging of the test and train data

A simple bind_rows() command merges the two data frames, resulting in . Before doing so, the program checks that the column names of both data frames are identical.

### Why data frames and not data tables?

Well, this code can probably be optimized for speed, but initial work with fread() to produce data tables resulted in RStudio crashes, whereas read.table() showed a stable behaviour.

The last part of the code, selecting a subset of variables and producing mean values, was done after conversion to the **tbl_df** class using the package **{dplyr}**.



