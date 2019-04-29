classdef AssessmentAggregatedClassificationResults < handle
    properties (Access = public)
        precisionPerClass;
        recallPerClass;
        accuracy;
        precision;
        recall;
        f1Score;
    end
    
    properties (Access = private)
        confusionMatrix ConfusionMatrix;
    end
    
    properties (Dependent)
        classNames;
    end
    
    methods
        function classNames = get.classNames(obj)
            classNames = obj.confusionMatrix.classNames;
        end
    end
    
    methods (Access = public)
        function obj = AssessmentAggregatedClassificationResults(confusionMatrix)
            obj.confusionMatrix = confusionMatrix;
            obj.computeAccuracy(confusionMatrix);
            obj.computePrecisionPerClass(confusionMatrix);
            obj.computeRecallPerClass(confusionMatrix);
            obj.computeF1Score();
        end
    end
    
    methods (Access = private)
        function computeAccuracy(obj, confusionMatrix)
            obj.accuracy = trace(confusionMatrix.confusionMatrixData)/sum(confusionMatrix.confusionMatrixData(:));
        end
        
        function computeRecallPerClass(obj, confusionMatrix)
            numClasses = size(confusionMatrix.confusionMatrixData,1);
            obj.recallPerClass = zeros(1,numClasses);
            
            for i = 1 : numClasses
                obj.recallPerClass(i) = confusionMatrix.confusionMatrixData(i,i)/sum(confusionMatrix.confusionMatrixData(i,:));
            end
            
            obj.recallPerClass(isnan(obj.recallPerClass))=[];
            obj.recall = nanmean(obj.recallPerClass);
        end
        
        function computePrecisionPerClass(obj, confusionMatrix)
            
            numClasses = size(confusionMatrix.confusionMatrixData,1);
            obj.precisionPerClass = zeros(1,numClasses);
            
            for i = 1 : numClasses
                obj.precisionPerClass(i) = confusionMatrix.confusionMatrixData(i,i) / sum(confusionMatrix.confusionMatrixData(:,i));
            end
            
            obj.precisionPerClass(isnan(obj.precisionPerClass))=[];
            obj.precision = nanmean(obj.precisionPerClass);
        end
        
        function computeF1Score(obj)
            obj.f1Score = 2 * obj.precision * obj.recall / (obj.precision + obj.recall);
        end
    end
    
end