classdef Constants < handle
    
    properties (Access = public, Constant)

        classesPath = './data/classes.txt';
        annotationsPath = './data/annotations';
        markersPath = './data/markers';
        dataPath = './data/rawdata';
        precomputedPath = './data/precomputed';
        synchronisationClassStr = 'synchronisation';
        SynchronisatonMarker = 3;
    end
end