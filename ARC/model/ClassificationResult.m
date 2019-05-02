classdef ClassificationResult < handle
    properties (Access = public)
        predictedClasses;
        table;
    end
    
    properties (Dependent)
        classNames;
        truthClasses;
    end
    
    methods
        function classNames = get.classNames(obj)
            classNames = obj.table.classNames;
        end
        
        function set.classNames(obj, classNames)
            obj.table.classNames = classNames;
        end
        
        function truthClasses = get.truthClasses(obj)
            truthClasses = obj.table.label;
        end
        
        function set.truthClasses(obj, truthClasses)
            obj.table.label = truthClasses;
        end
    end
    
    methods (Access = public)
        function obj = ClassificationResult(predictedClasses,table)
            if nargin > 0
                obj.predictedClasses = predictedClasses;
                obj.table = table;
            end
        end
    end
end