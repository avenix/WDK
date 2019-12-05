# Wearables Development Toolkit (WDK) Setup Guide

## Requirements
* Matlab 2019a or greater. *Note: if you have an older Matlab version, you might need to do minor changes to some source files due to changes in Matlab's syntax.*
* [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html). *Note: clicking on the *Get More Apps* button on Matlab's toolbar.*

## Installation
* ```git clone https://github.com/avenix/WDK.git```
* in Matlab, open the WDK's repository and add its root to Matlab's path:  `addpath(genpath('./'))` in the console:
![Checking Matlab Path](images/matlabPath.png)
* use the Apps in each directory (e.g. *AnnotationApp* in *1-Annotation/*).
* the '*./data*' directory should contain the following files and directories defined in the *Constants.m* file:

```
kLabelsPath = './data/annotations/labels.txt';
kAnnotationsPath = './data/annotations';
kMarkersPath = './data/markers';
kDataPath = './data/rawdata';
kCachePath = './data/cache';
kLabelGroupingsPath = './data/labeling';
kARChainsPath = './data/ARChains';
kVideosPath = './data/videos';
```
 
 ## Getting started
 1. The WDK loads *.txt* or *.mat* files located in the *./data/rawdata/* directory. For faster loading, you should use the WDK's binary format. The *Data Conversion App* can be used to convert txt files (in CSV format) to the WDK's binary format (see below an example how to use the *Data Conversion App*).
2. The labels used by the WDK should be listed in the *.data/annotations/labels.txt* file.
3. Use the *Data Annotation App* to create a ground truth data set.
4. (optional) Define a label grouping. A label grouping describes how labels annotated are mapped to groups used by the different Apps in the WDK. The following label grouping maps labels *label1*, *label2* and *label3* into *Group1* and *label4* and *label5* to *Group2*.
```
#Group1 
class1
class2
class3

#Group2
class4
class5
```
If no label grouping is defined, the WDK uses the *defaultLabelingStrategy* which maps each label to a class with the same name.

*Note: Labels listed in a label grouping should be defined in the './data/annotations/labels.txt' file*.

*Note: Label groupings should be placed in the './data/labeling/' directory*.

*Note: Labels should be mapped to a single group in a labeling strategy. Labels that are left ungrouped in a labeling strategy will be assigned to its own group automatically*.
 

 ## Data Conversion

 The *Data Conversion App* can be used to convert your *.txt* data file to the format needed by the rest of the toolkit. The tool can load comma-separated files that look like:  
 ```
 ax,ay,az,gx,gy,gz
 -0.01940918,-0.05337523,-0.00286865,-0.2326506,0.5926659,0.10809
 -0.01986694,-0.05346679,-0.003265379,0.002755165,-0.01103783
 ...
 ```
 You can save a loaded file in the WDK's format by clicking on *Save Data WDK*. 

 *Note: by default, the Data Conversion App loads data files from the ./data/rawdata/ directory. Converted files are saved to the "./" root directory. You should copy your converted files to the "./data/rawdata/"  directory for the other tools to be able to use them.*
 
 ## Troubleshooting

Most errors after installation are related to pathing issues. Double-check you have added the entire WDK to Matlab path. If you have added files to the data directory, be sure they are added to Matlab's path.

The WDK handles errors and displays them over Matlab's console:

> 'Error. Invalid annotation class'. 

An annotation file in *./data/annotations/* contains an invalid label (i.e. a label which is not listed in the *./data/annotations/labels.txt* file).

> 'Index in position 1 exceeds array bounds (must not exceed XXX).'

 > 'Warning - FeatureSelector - every segment has same value. Feature selection might fail';
 
 The current version of the *FeatureSelector* uses the mRMR algorithm to select the most relevant features. The mRMR algorithm will fail if every feature vector contains the same value for a particular feature.

The WDK has been developed based on Matlab's version 2018b. If Matlab crashes with these errors:

 > 'Too many input arguments'
  
 > 'Unrecognized property 'Scrollable' for class 'matlab.ui.Figure'
 
double-check that your are using Matlab 2018b or later. 

*Note: The data in the './data/rawData' directory should be consistent. You will get errors if different files have different amount of columns.* 

*Note: Double-check that the './data/annotations/' directory contains an annotation file for each data file in './data/rawdata/'.* 

*Note: A common error happens due to selecting incompatible computer nodes. As the WDK does not do type-checking on the computers selected, the first computer that received incompatible data will crash. If Matlab produces an error message with 'Computer.ExecuteChain' in its stack-trace, it is most likely due to an incompatible set of computers being used. In this case, double-check the input and output types of each computer.*

* the feature selection feature in the WDK uses the mRMR library for feature selection. If you get an error '*estpab function not found*', then you need to:
```
cd libraries/mRMR_0.9/mi/
mex -setup C++ 
makeosmex
```
