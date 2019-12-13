
classdef RangeAnnotation < handle
    properties (Access = public)
        startSample;
        endSample;
        label;
    end
    
    properties (Dependent)
        nSamples;
    end
    
    methods
        function n = get.nSamples(obj)
            n = obj.endSample - obj.startSample + 1;
        end
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