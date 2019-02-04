%performs leave one subject out cross validation
classdef LeaveOneOutCrossValidator < handle
    properties (Access = public)
        nFeatures = 20;
        shouldNormalizeFeatures = true;
        shouldSelectFeatures = true;
        classifier;
        tableSet;
    end
    
    properties (Access = private)
        dataNormalizer;
        featureSelector;
    end
    
    methods (Access = public)
        
        function obj = LeaveOneOutCrossValidator()
            obj.dataNormalizer = FeatureNormalizer();
            obj.featureSelector = FeatureSelector();
        end
        
        function truthLabels = getTruthLabels(obj)
            truthLabels = obj.tableSet.getAllLabels();
        end
        
        %receives a table set, cross validates and
        %returns a cell array with an array of labels in each cell
        function labels = validate(obj)
            
            nTables = obj.tableSet.nTables;
            labels = cell(1,nTables);
            
            for i = 1 : nTables
                trainIndices = [1 : i-1, i+1 : nTables];
                testIndex = i;
                
                trainTable = obj.tableSet.mergedTableForIndices(trainIndices);
                testTable = obj.tableSet.mergedTableForIndices(testIndex);
                
                %normalisation
                if(obj.shouldNormalizeFeatures)
                    obj.dataNormalizer.fit(trainTable);
                    trainTable = obj.dataNormalizer.normalize(trainTable);
                    testTable = obj.dataNormalizer.normalize(testTable);
                end
                
                %feature selection
                if(obj.shouldSelectFeatures)
                    obj.featureSelector.findBestFeaturesForTable(trainTable,obj.nFeatures);
                    obj.featureSelector.selectFeaturesForTable(trainTable);
                    obj.featureSelector.selectFeaturesForTable(testTable);
                end
                
                %classification
                obj.classifier.train(trainTable);
                labels{i} = obj.classifier.test(testTable);
            end
            
            labels = cat(1,labels{:});
        end
    end
end