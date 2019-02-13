classdef PropertyTestFix < handle
    properties (Access = public)
        name;
        minValue = 0;
        interval = 1;
        maxValue = 0;
    end
   
    methods (Access = public)
        function obj= PropertyTestFix(name, minValue, interval,maxValue)
            if nargin > 0
                obj.name = name;
                if nargin > 1
                    obj.minValue = minValue;
                    obj.interval = interval;
                    obj.maxValue = maxValue;
                end
            end
        end
    end
end
