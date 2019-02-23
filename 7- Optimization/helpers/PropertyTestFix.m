classdef PropertyTestFix <  handle
    properties (Access = public)
        name;
        minValue = 0;
        interval = 1;
        maxValue = 1;
    end
    
    properties (Dependent)
        nCombinations;
    end
        
    methods
        function n = get.nCombinations(obj)
            n = floor((obj.maxValue - obj.minValue + 1) / obj.interval);
        end
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
        
        function properties = generateCombinations(obj)
            properties = repmat(Property,1,obj.nCombinations);
            propertyCount = 1;
            for i = obj.minValue : obj.interval : obj.maxValue
                properties(propertyCount) = Property(obj.name,i);
                propertyCount = propertyCount + 1;
            end
        end
    end
end
