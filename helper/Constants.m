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
    end
end