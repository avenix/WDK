
classdef HistoryComponent < Algorithm
    
    properties (Access = public)
    end
    
    methods (Access = public)
        function obj = HistoryComponent()
            obj.name = 'historyComponent';
            obj.inputPort = DataType.kClassificationResult;
            obj.outputPort = DataType.kAny;
        end
            
        %receives an array of instances of ClassificationResult
        function output = compute(~,classificationResults)
            output = [];
            
            nLabels = length(classificationResults);
            for i = 1 : nLabels
                classificationResult = classificationResults(i);
                plot(classificationResult.predictedClasses,'*');
            end
        end
    end
    
end
