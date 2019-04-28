classdef ClassificationResult < handle
    properties (Access = public)
        predictedClasses;
        truthClasses;
    end
    
    methods (Access = public)
        function obj = ClassificationResult(predictedClasses,truthClasses)
            if nargin > 0
                obj.predictedClasses = predictedClasses;
                obj.truthClasses = truthClasses;
            end
        end
    end
end