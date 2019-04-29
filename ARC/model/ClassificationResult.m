classdef ClassificationResult < handle
    properties (Access = public)
        predictedClasses;
        truthClasses;
        classNames;
    end
    
    methods (Access = public)
        function obj = ClassificationResult(predictedClasses,truthClasses,classNames)
            if nargin > 0
                obj.predictedClasses = predictedClasses;
                obj.truthClasses = truthClasses;
                if nargin == 3
                    obj.classNames = classNames;
                end
            end
        end
    end
end