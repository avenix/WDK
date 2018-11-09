
classdef RangeAnnotation < handle
    properties
        startSample;
        endSample;
        label;
    end
    
    methods
        function obj = RangeAnnotation(startSample,endSample,label)
            if nargin>1
                obj.startSample = startSample;
                obj.endSample = endSample;
                obj.label = label;
            end
        end
    end
end