classdef DataType
    properties (Access = public, Constant)
        kDataFile = 0;
        kSignal = 1;
        kSignal2 = 2;
        kSignal3 = 3;
        kSignalN = 4;
        kEvent = 5;
        kSegment = 6;
        kFeature = 7;
        kFeatureVector = 8;
        kTable = 9;
        kTableSet = 10;
        kLabels = 11;
        kAny = 12;
        kNull = 13;
        kAnnotation = 14;
        kClassificationResult = 15;
    end
    
    properties (Access = public, Constant)
        TypeStrings = {'DataFile' , 'Signal (1D)', 'Signal (2D)', 'Signal (3D)',...
            'Signal', 'Event', 'Segment', 'Feature', 'FeatureVector', ...
            'Table','TableSet', 'Labels', 'Any', 'Null', 'Annotation', 'ClassificationResult'};
    end
    
    methods (Access = public, Static)
        function str = DataTypeToString(type)
            str = DataType.TypeStrings{type+1};
        end
    end
end
