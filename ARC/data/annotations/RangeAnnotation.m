
classdef RangeAnnotation < handle
    properties (Access = public)
        startSample;
        endSample;
        label;
    end
    
    methods (Access = public)
        function obj = RangeAnnotation(startSample,endSample,label)
            if nargin > 0
                obj.startSample = startSample;
                obj.endSample = endSample;
                obj.label = label;
            end
        end
    end
end