%performs leave one subject out cross validation
classdef HoldOutValidator < handle
    properties (Access = public)
        nFeatures = 20;
        shouldNormalizeFeatures = true;
        shouldSelectFeatures = true;
        testTable;
        trainTable;
        classifier;
    end
    
    properties (Access = private)
        dataNormalizer;
        featureSelector;
    end
    
    methods (Access = public)
        
        function obj = HoldOutValidator()
            %obj.dataNormalizer = FeatureNormalizer();
            %obj.featureSelector = FeatureSelector();
        end
        
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