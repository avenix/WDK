classdef DetailedClassificationResults < handle
    properties (Access = public)
        fileName; 
        segments;
        validationResult;
    end
    
    methods (Access = public)
        function obj = DetailedClassificationResults()
        end
        
        function labels = getAllTruthLabels(obj)
            labels = vertcat(obj.validationResult.truthClasses);
        end
        
        function labels = getAllPredictedLabels(obj)
            labels = vertcat(obj.validationResult.predictedClasses);
        end
    end
end