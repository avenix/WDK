classdef ConfusionMatrix < handle
    properties (GetAccess = public)
        data;
        accuracy;
        precisionPerClass;
        recallPerClass;
        precision;
        recall;
        nClasses;
        containsNullClass;
    end
    
    methods (Access = public)
        function obj = ConfusionMatrix(data)
            obj.data = data;
            obj.computeAccuracy();
            obj.computePrecisionPerClass();
            obj.computeRecallPerClass();
            obj.nClasses = size(obj.data,1);
        end
    end
    
    methods (Access = private)
        function computeAccuracy(obj)
            obj.accuracy = trace(obj.data)/sum(obj.data(:));
        end
        
        function computeRecallPerClass(obj)
            numClasses = size(obj.data,1);
            obj.recallPerClass = zeros(1,numClasses);
            
            for i = 1 : numClasses
                obj.recallPerClass(i) = obj.data(i,i)/sum(obj.data(i,:));
            end
            
            obj.recallPerClass(isnan(obj.recallPerClass))=[];
            obj.recall = nanmean(obj.recallPerClass);
        end
        
        function computePrecisionPerClass(obj)
            
            numClasses = size(obj.data,1);
            obj.precisionPerClass = zeros(1,numClasses);
            
            for i = 1 : numClasses
                obj.precisionPerClass(i) = obj.data(i,i) / sum(obj.data(:,i));
            end
            
            obj.precisionPerClass(isnan(obj.precisionPerClass))=[];
            obj.precision = nanmean(obj.precisionPerClass);
        end
    end
    
end