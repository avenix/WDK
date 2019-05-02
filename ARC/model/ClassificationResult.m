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
        function classNnames = get.classNames(obj)
            classNnames = obj.table.classNames;
        end
        
        function truthClasses = get.truthClasses(obj)
            truthClasses = obj.table.label;
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