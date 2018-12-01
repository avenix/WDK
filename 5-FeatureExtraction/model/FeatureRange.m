classdef FeatureRange < handle
    properties (Access = public)
        rangeStart;
        rangeEnd;
    end
    
    methods (Access = public)
        function obj = FeatureRange(rangeStart,rangeEnd)
            obj.rangeStart = rangeStart;
            obj.rangeEnd = rangeEnd;
        end
        
        function str = toString(obj)
            str = sprintf('%d_%d',obj.rangeStart,obj.rangeEnd);
        end
    end
end