%performs leave one subject out cross validation
classdef HoldOutValidator < handle
    properties (Access = public)
        testTable;
        trainTable;
        classifier;
    end

    methods (Access = public)
        
        function truthLabels = getTruthLabels(obj)
            truthLabels = obj.testTable.label;
        end
        
        function labels = validate(obj)
            if isempty(obj.trainTable) || isempty(obj.testTable)
                labels = [];
            else
                obj.classifier.train(obj.trainTable);
                labels = obj.classifier.test(obj.testTable);
            end
        end
    end
end