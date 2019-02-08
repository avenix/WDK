classdef ComputerPortType < handle
    properties (Constant)
        kDataFile = 0;
        kSignal = 1;
        kEvent = 2;
        kSegment = 3;
        kFeature = 4;
        kFeatureVector = 5;
        kTable = 6;
        kAny = 7;
        kNull = 8;
    end
end