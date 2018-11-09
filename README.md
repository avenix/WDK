# Wearables Development Toolkit

This toolkit facilitates the development of wearable device applications. Most wearable device applications follow the Activity Recognition Chain:

![Activity Recognition Chain](images/ARC.png)

*Note: Check my Matlab tutorial on the Activity Recognition Chain for wearables: <https://github.com/avenix/ARC-Tutorial/>
*

The usual activities a developer of a wearable device application will have to engage in are: data collection, data annotation, algorithm development, algorithm evaluation and deployment (i.e. integration of the code into the wearable device): 

![Activity Recognition Chain Development](images/ARCDevelopment.png)

 This Toolkit offers different tools for each of these activities.
 
## Data Collection

Once you have collected data you can use the *DataLoaderApp* in *0-DataLoader* to do a first check on the data and convert it to Matlab's binary format, used by the rest of the toolkit. 

![DataLoaderApp](images/0-DataLoaderApp)

*Note: the DataLoader can load files in comma separated format.*
*Note: by default, the DataLoaderApp will load data files from the ./data/rawdata/ directory*

## Data Annotation

To train the wearable application to recognize a specific pattern and to test whether it works as expected, you need to annotate the data you collected. Depending on your application, you will want to annotate sudden events (event-based annotation) or activities that have a duration in time (activity-based annotation). The *DataAnnotationApp* offers functionality to annotate time series data. 

It might be hard to annotate time series data without a reference data. Therefore, *DataAnnotationApp* can import and display markers on top of the time series data. Currently, the time series supports markers created with ![DaVinciResolve](https://www.blackmagicdesign.com/products/davinciresolve/) in .edl format. 

![Data Annotation App](images/1-DataAnnotationApp.png)

*Note: by default, the DataAnnotationApp will load annotation files from the ./data/annotations/ directory. Saved annotation files will be stored in the ./ directory*.
*Note: markers in .edl format will be read from the ./data/markers directory*.


## Setup
* install Matlab
* `git clone git@github.com:avenix/ARC-Tutorial.git`
* in Matlab, `addpath(genpath('./'))`
* run the App in every directory.
 
## References
You will find more information on Andreas Bulling's article: https://dl.acm.org/citation.cfm?id=2499621
and a few example applications:
1. https://www.mdpi.com/2414-4088/2/2/27
2. https://dl.acm.org/citation.cfm?id=3267267

## Contact
Juan Haladjian
haladjia@in.tum.de
