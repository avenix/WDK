# Wearables Development Toolkit

The Warables Development Toolkit facilitates the development of wearable device applications. The usual activities involved in the development of such applications are: data collection, data annotation, algorithm development, algorithm evaluation and deployment (i.e. integration of the code into the wearable device): 

![Activity Recognition Chain Development](images/ARCDevelopment.png)

 This Toolkit offers different tools for each of these activities.

*Note: Check my Matlab tutorial on the Activity Recognition Chain for wearables: <https://github.com/avenix/ARC-Tutorial/>*

## Data Collection

Once you have data available for analysis, you can use the *DataLoaderApp* in *0-DataLoader* to do a first check on the data and convert it to Matlab's binary format, used by the rest of the toolkit. 

![DataLoaderApp](images/0-DataLoaderApp.png)

*Note: the DataLoader can load any file in comma separated format.*
*Note: by default, the DataLoaderApp will load data files from the ./data/rawdata/ directory*

## Data Annotation

To train the wearable application to recognize a specific pattern and to test whether it works as expected, you need to annotate the data you collected. The *DataAnnotationApp* offers functionality to annotate time series data.  Depending on your application, you will want to annotate sudden events or activities that have a duration in time. The *DataAnnotationApp* supports both kinds of annotations.

It might be hard to annotate time series data without a reference. The *DataAnnotationApp* can import and display reference markers on top of the time series data. Currently, the *DataAnnotationApp* supports markers created with the video annotation tool [DaVinciResolve](https://www.blackmagicdesign.com/products/davinciresolve/) in *.edl* format.

In order to display markers on top of the time series data, the markers need to be aligned (synchronised) to the time series data. In order to do this, your markers *.edl* file should contain a marker in green color in the beginning and another one in the end of the file. These markers will be automatically matched to the first and last annotation with the label *synchronisaton'. This is the typical annotation flow:

1. Annotate the video using DaVinci Resolve. Use a green marker to annotate a special event, ideally in the beginning and end of the file. (e.g. the user shakes the sensor three times in front of the camera).
2. Export the markers to an *.edl* file. This can be done by: right click on the Timeline, timelines, export, Timeline markers to .EDL...
3. Copy the markers to the *data/markers/* directory.
4. Open the *DataAnnotationApp* and annotate the special events using the *synchronisation* class.
5. Reopen the *DataAnnotationApp*. This time the markers should be properly aligned with the data. You can now use  these markers to annotate the rest of the data.

![Data Annotation App](images/1-DataAnnotationApp.png)

*Note: by default, the DataAnnotationApp will load annotation files from the ./data/annotations/ directory. Saved annotation files will be stored in the root './' directory*.
*Note: markers in .edl format will be read from the ./data/markers directory*.

## Application Development

Most wearable device applications follow the Activity Recognition Chain:
![Activity Recognition Chain](images/ARC.png)

### Preprocessing

The *SignalExplorerApp* can be used to display and compare the different classes to each other, as well as the effects of several signal processing methods.


Currently, the following signal processing methods are supported:

Filters:
- HighPassFilter: Butterworth high-pass filter
- LowPassFilter: Butterworth low-pass filter

Energy:
- EnergyComputer: [Energy](http://www.sciweavers.org/tex2img.php?eq=E%28x_i%29%20%3D%20%20a_x%28x_i%29%5E2%20%2B%20a_y%28x_i%29%5E2%20%2B%20a_z%28x_i%29%5E2&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
- NormComputer: [Norm](http://www.sciweavers.org/tex2img.php?eq=E%28x_i%29%20%3D%20%20%5Cleft%7C%20a_x%28x_i%29%20%5Cright%7C%20%2B%20%5Cleft%7C%20a_y%28x_i%29%20%5Cright%7C%20%2B%20%5Cleft%7C%20a_z%28x_i%29%20%5Cright%7C&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
- S1Computer: computes ![S1](http://www.sciweavers.org/tex2img.php?eq=S_1%28k%2Ci%2CX_i%2CT%29%20%3D%20%20%5Cfrac%7Bmax%28x%2Bi%20-%20x_%7Bi-1%7D%2C%20x_i%20-%20x_%7Bi-2%7D%2C...%2Cx_i%20-%20x_%7Bi-k%7D%29%20%2B%20max%28x_i-x_%7Bi%2B1%7D%2Cx_i-x_%7Bi%2B2%7D%2C...%2Cx_i-x_%7Bi%2Bk%7D%29%7D%7B2%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
- S2Computer: computes ![S2](http://www.sciweavers.org/tex2img.php?eq=S_2%28k%2Ci%2CX_i%2CT%29%20%3D%20%20%5Cfrac%7B%5Cfrac%7Bmax%28x%2Bi%20-%20x_%7Bi-1%7D%2C%20x_i%20-%20x_%7Bi-2%7D%2C...%2Cx_i%20-%20x_%7Bi-k%7D%29%7D%7Bk%7D%20%2B%20%5Cfrac%7Bmax%28x_i-x_%7Bi%2B1%7D%2Cx_i-x_%7Bi%2B2%7D%2C...%2Cx_i-x_%7Bi%2Bk%7D%29%7D%7Bk%7D%7D%7B2%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

[comment]: <> E(x_i) =  \left| a_x(x_i) \right| + \left| a_y(x_i) \right| + \left| a_z(x_i) \right|
[comment]: <> E(x_i) =  a_x(x_i)^2 + a_y(x_i)^2 + a_z(x_i)^2
[comment]: <> S_1(k,i,X_i,T) =  \frac{max(x+i - x_{i-1}, x_i - x_{i-2},...,x_i - x_{i-k}) + max(x_i-x_{i+1},x_i-x_{i+2},...,x_i-x_{i+k})}{2}
[comment]: <> S_2(k,i,X_i,T) =  \frac{\frac{max(x+i - x_{i-1}, x_i - x_{i-2},...,x_i - x_{i-k})}{k} + \frac{max(x_i-x_{i+1},x_i-x_{i+2},...,x_i-x_{i+k})}{k}}{2}

Helpers
- 

### Feature Extraction

The *FeatureExtractor* class extracts the following time-domain features:

- statistical feature: mean, std, var, max, min, corr 
- Cross correlation: a measure of the similarity between two waveforms. It
calculates the dot product between the signal and a shifted version of
another signal.
- Correlaton coefficients (also called Pearson correlation coefficients): cov(x,y) / (std(x)*std(y)
- DC component: the first component of the frequency domain representation
of a signal
- SVM: signal vector magnitude (normalized). The sum of the magnitude. Calculated for
acceleration and rotation
- SMA: Signal Magnitude Area. Similar to AUC, but easier to compute and
includes all three components x,y,z. Computed for Acceleration and
Rotation.
- quantile(signal,n): the cutpoints dividing a set of values into n+1 segments.
quantile(signal,2) sorts the values in the signal and dividides them in three groups
and returns the two cutpoints separating the three groups
- entropy: gives an indication of the amount of information in a signal.
More information less entropy. Flipping a coin has high entropy of 1. If there
is 100 / 0% probability that an event will occur, the entropy is 0.
- kurtosis: describes the tailedness of the distribution of values in the
signal
- skewness: describes the distribution of values with respect to the mean. A
positive skewness indicates that most values in the segment are concentrated at
the left of the distribution and there is a tail on the right
- IQR: interquartile range. The difference between the median of Q3 and Q1 where Q3 and Q1 are
intervals separated by the median of the dataset. Indicates variability in
the signal.
- MAD: mean absolute deviation.
- AAV: average absolute acceleration variation.
- trapz: The area under the signal's curve integrated numerically with the t
trapezoid method
- ZRC: zero crossing rate: how often a signal crosses the 0 threshold:
TODO. Check the zero crossing using the mean as sample
- RMS: root mean square
- duration: the number of samples in the segment (makes sense if the segmentaton produced segments with different amounts of samples)

and the following frequency-domain features:

- spectral spread: indicates the variance in the distribution of
frequencies
- spectral centroid: Indicates where the "center of mass" of the spectrum is located.
- spectral flatness: provides a way to quantify how noise-like a sound is.
white noise has peaks in all frequencies making its spectrum look flat
- spectral entropy: indicates how chaotic / how much informatiomn there is
in the frequency distribution
- spectral energy: the energy of the frequency domain (sum of squared values of dft coefficients).
- spectral density: the probability distribution of the spectrum. Not a
feature but a transformation that can result in other features.

Coming soon: Frequency domain features (maximum frequency, value and ratio,
spectral entropy, 10 cepstral coefficients, Fourier transform: coefficients grouped in four logarithmic
bands, maximum spectral frequency ), wavelet analysis, mean crossing rate.

*Note: use the extractFeatures() method of the FeatureExtractor. This method receives a *Segment* as input and returns i) an array of features and ii) an array with the name of each feature in i)*.

## Setup
* install Matlab
* `git clone git@github.com:avenix/ARC-Tutorial.git`
* in Matlab, `addpath(genpath('./'))`
* open the App file in each directory (e.g. *DataAnnotationApp* in *1-DataAnnotation*).
 
 ## Getting started
1. Place your data files (.txt or .mat) in the *./data/rawdata/* directory
2. If the files are in *.txt* format, you might want to convert them to a binary format with the *DataLoaderApp*
3. Define your classes in the *classes.txt* file. 
4. Open the *DataAnnotationApp* to annotate your data. Annotations created with the App should be copied into the *./data/annotations*
5. Sometimes we will want to group annotations for the data analysis. For example, we might want to consider events annotated as *low jump*, *mid jump* and *high jump* as a *jump* for a first data analysis. This can be achieved by defining a labeling strategy. A labeling strategy maps annotations made to groups, which is provided in the following *.txt* format: 
```
#Group1 
class1
class2
class3

#Group2
class4
class5
```
Note that you dont need to assign every class to a group. A class which is left ungrouped will be assigned to its own group automatically. Ensure that the classes you provide have been defined in the *./data/classes.txt* file and that no class belongs to two groups at the same time. Place your labeling strategy files in the *./data/labeling/*
6. The WDK offers a Matlab App to support you in each stage of the development your wearable applications. Check in each directory for the App file.

## Tipps

* The default data paths can be changed from the *Constants* class.  
 
 ## Troubleshooting

> 'Error - no labeling strategy available'.

Check the *./data/labeling/* directory. There might be no *.txt* file containing a labeling strategy.

> 'Error. Invalid annotation class'. 

An annotation file in *./data/annotations/* contains an invalid label (i.e. a class which is not listed in the *./data/classes.txt* file)  

> 'Error. class not defined'
 
 The *ClassesMap* triggers this error when it is requested to map a string of an invalid class. This error might be due to a file in the  *./data/labeling/* directory containing an invalid class name.
 
 > 'Warning - FeatureSelector - every segment has same value. Feature selection might fail';
 
 The current version of the *FeatureSelector* uses the mRMR algorithm to select the most relevant features. The mRMR algorithm will fail if every value of a feature is the same.
 
Furthermore, the data in the *./data/rawData* directory should be consistent. You will get errors if different files have different amount of columns. 
 
## References
You will find more information about the human activity recognition on Andreas Bulling's article: https://dl.acm.org/citation.cfm?id=2499621

A few example applications:
1. https://www.mdpi.com/2414-4088/2/2/27
2. https://dl.acm.org/citation.cfm?id=3267267

* [Peak detection algorithms by Palshikar](http://constans.pbworks.com/w/file/fetch/120908295/Simple_Algorithms_for_Peak_Detection_in_Time-Serie.pdf)

## Contact
Juan Haladjian
haladjia@in.tum.de
