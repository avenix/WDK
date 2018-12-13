classdef Constants < handle
    
    properties (Access = public, Constant)

        classesPath = './data/classes.txt';
        annotationsPath = './data/annotations';
        markersPath = './data/markers';
        dataPath = './data/rawdata';
        precomputedPath = './data/cache';
        labelingStrategiesPath = './data/labeling';
        synchronisationClassStr = 'synchronisation';
        nullClassGroupStr = 'null';
        SynchronisatonMarker = 3;
        
        kTrainDataFileName = 'trainData';
        kTestDataFileName = 'testData';
        kNormalisationFileName = 'normalisationValues.txt';
        kDetectedEventsFileName = 'detetedEvents.txt';
        
        
        kInconsistentAnnotationAndDataFiles = 'Error - the number of annotations is different than the number of data files.';
        kNoLabelingStrategyAvailableError = 'Error - no labeling strategy file found. Double check that Matlabs path and Constants.m file are consistent';
        kInvalidAnnotationClassError = 'Error - invalid annotation class';
        kUndefinedClassError = 'Error - class not defined. Double check that the the strings in the annotations files are defined in the classes file';
        kInvalidInputSegmentError = 'Error - FeatureExtractor - input segment has different amount of columns than expected';
        
        kNoDataFileFoundWarning = 'Warning - no data file found. Double check that Matlabs path and Constants.m file are consistent';
        kLabelingStrategyNotSetWarning = 'Warning - DetectionResultsComputer - calling computeDetectionResults but labelingStrategy not set'
        kIncorretlyMappedClassWarning = 'Warning - GroupedClassLabeling - class is not mapped correctly';
        kConstantFeaturesWarning = 'Warning - FeatureSelector - every segment has same value. Feature selection might fail';
    end
end