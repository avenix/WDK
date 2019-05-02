classdef AssessmentDetailedClassificationResult < handle
    properties (Access = public)
        segments;
        annotations;
        classificationResult ClassificationResult;
    end
    
    properties (Dependent)
        fileName;
    end
    
    methods
        function fn = get.fileName(obj)
            fn = obj.classificationResult.table.file.fileName;
        end
    end
    
    methods (Access = public)
        function obj = AssessmentDetailedClassificationResult()
        end
        
        function labels = getAllTruthLabels(obj)
            labels = vertcat(obj.classificationResult.truthClasses);
        end
        
        function labels = getAllPredictedLabels(obj)
            labels = vertcat(obj.classificationResult.predictedClasses);
        end
    end
end