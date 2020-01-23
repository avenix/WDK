%Contains global constants
classdef Constants < handle
    
    properties (Access = public, Constant)
        
        %% Path files and directory
        kShouldSetupMatlabPath = true;
        
        kLabelsPath = './data/annotations/labels.txt';
        kAnnotationsPath = './data/annotations';
        kMarkersPath = './data/markers';
        kDataPath = './data/rawdata';
        kCachePath = './data/cache';
        kLabelGroupingsPath = './data/labeling';
        kARChainsPath = './data/ARChains';
        kVideosPath = './data/videos';
        
        %% Metrics
        kReferenceComputingTime = 6.5394e-04;
        kSensorDataBytes = 2;%short
        kFeatureBytes = 4;%float
        kClassificationResultBytes = 9;%ts: 8 bytes, label: 1 byte
        
        %% UI
        kUIColors = {[191,108,0] / 255, [13,45,126] / 255, [25,110,16] / 255};
        
        kPlotColors = {[31,119,180] / 255,[255,127,14] / 255,[44,160,44] / 255,...
            [214,39,40] / 255,[148,103,189] / 255,[140,86,75] / 255};
        
        kCorrectColor = [25,110,16]/255;
        kWrongColor = 'red';
        kMissedColor = [1,0.5,0];

        %% Strings
        kComputerTypeStrings = {'kDataFile','kSignal','kSignal2','kSignal3','kSignalN', 'kEvent','kSegment', 'kFeature','kFeatureVector', 'kTable', 'kAny', 'kNull'};
        
        kSharedVariableCurrentDataFile = 'currentFile';
        kSharedVariableCurrentData = 'currentData';
        kSharedVariableCurrentAnnotationFile = 'annotationFile';
        kSharedVariableCurrentLabelingStrategy = 'currentLabelingStrategy';
        
        %% Errors
        kNoLabelingStrategyAvailableError = 'Error - no labeling strategy file found. Double check that Matlabs path and the paths in the Constants.m file are consistent';
        kInvalidAnnotationClassError = 'Error - invalid annotation class';
        kUndefinedClassError = 'Error - class not defined. Double check that the strings in the annotations files are defined in the classes file';
        kInvalidInputSegmentError = 'Error - FeatureExtractor - input segment has different amount of columns than expected';
        kInvalidFilterComputedError = 'Error - Filtered Data is empty. Double-check input parameters passed to a computer';
        kInvalidInputError = 'Error - the input data provided does not match the expected input';
        kInvalidInputMagnitudeError = 'Error - Invalid input Signal. It should have 3 columnns';
        kEmptyInputError = 'Error - received an empty object';
        
        %% Warnings
        kNoDataFileFoundWarning = 'Warning - no data file found. Double check that Matlabs path and the paths in the Constants.m file are consistent';
        kLabelingStrategyNotSetWarning = 'Warning - DetectionResultsComputer - calling computeDetectionResults but labelingStrategy not set'
        kPositiveLabelsNotSetWarning = 'Warning - DetectionResultsComputer - calling computeDetectionResults but positiveLabels not set'
        kIncorretlyMappedClassWarning = 'Warning - GroupedClassLabeling - class is not mapped correctly';
        kConstantFeaturesWarning = 'Warning - FeatureSelector - every segment has same value. Feature selection might fail';
        kAlgorithmExecutionFailedWarning = 'Warning - Algorithm execution failed';
        kInvalidSynchronizationFileWarning = 'Warning - Invalid synchronization file loaded';
        
        %% Messages
        kLoadingVideoMessage = 'Message - AnnotationVideoPlayer - loading video ';
    end
end