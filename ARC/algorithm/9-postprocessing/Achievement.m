classdef Achievement < handle
    properties (Access = public)
        comparissonType;
        comparissonValue;
    end
    
    methods (Access = public)
        function obj = Achievement(comparissonType,comparissonValue)
            obj.comparissonType = comparissonType;
            obj.comparissonValue = comparissonValue;
        end
        
        function b = testAchievement(obj,predictedClass)
            
            expression = sprintf("predictedClass %s obj.comparissonValue",obj.comparissonType);
            b = eval(expression);
        end
    end
    
end