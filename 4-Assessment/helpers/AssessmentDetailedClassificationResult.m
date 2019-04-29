classdef AssessmentDetailedClassificationResult < handle
    properties (Access = public)
        fileName; 
        segments;
        validationResult ClassificationResult;
    end
    
    methods (Access = public)
        function obj = AssessmentDetailedClassificationResult()
        end
        
        function labels = getAllTruthLabels(obj)
            labels = vertcat(obj.validationResult.truthClasses);
        end
        
        function labels = getAllPredictedLabels(obj)
            labels = vertcat(obj.validationResult.predictedClasses);
        end
    end
end