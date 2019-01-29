classdef Property < handle
    properties (Access = public)
        name;
        value = 0;
        minValue = 0;
        maxValue = 1;
    end
    
    methods (Access = public)
        function obj = Property(name,value,minValue,maxValue)
            obj.name = name;
            if nargin>1
                obj.value = value;
                if nargin > 2
                    obj.minValue = minValue;
                    obj.maxValue = maxValue;
                end
            end
        end
    end
end