classdef Constants < handle
    
    properties (Access = public, Constant)

        classesPath = './data2/classes.txt';
        annotationsPath = './data2/annotations';
        markersPath = './data2/markers';
        dataPath = './data2/rawdata';
        precomputedPath = './data2/cache';
        labelingStrategiesPath = './data2/labeling';
        synchronisationClassStr = 'synchronisation';
        nullClassGroupStr = 'null';
        SynchronisatonMarker = 3;
        
        kTrainDataFileName = 'trainData';
        kTestDataFileName = 'testData';
        kNormalisationFileName = 'normalisationValues.txt';
        kDetectedEventsFileName = 'detetedEvents.txt';
        
        
        kNoLabelingStrategyAvailableError = 'Error - no labeling strategy file found';
        kInvalidAnnotationClassError = 'Error - invalid annotation class';
        kUndefinedClassError = 'Error - class not defined';
        kInvalidInputSegmentError = 'Error - FeatureExtractor - input segment has different amount of columns than expected';
        
        kLabelingStrategyNotSetWarning = 'Warning - DetectionResultsComputer - calling computeDetectionResults but labelingStrategy not set'
        kIncorretlyMappedClassWarning = 'Warning - GroupedClassLabeling - class is not mapped correctly';
        kConstantFeaturesWarning = 'Warning - FeatureSelector - every segment has same value. Feature selection might fail';
    end
end