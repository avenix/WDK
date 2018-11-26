%performs leave one subject out cross validation
classdef Validator < handle
    properties (Access = public)
        nFeatures = 20;
    end
    
    methods (Access = public)
        
        function obj = Validator()
        end
        
        %receives a table set, cross validates and
        %returns a cell array with an array of labels in each cell
        function labels = validate(obj,tableSet,labelingStrategy)
            
            nTables = tableSet.NTables();
            
            dataNormalizer = DataNormalizer();
            
            labels = cell(1,nTables);
            
            for i = 1 : nTables
                trainIndices = [1 : i-1, i+1 : nTables];
                testIndex = i;
                
                trainTable = tableSet.tableForIndices(trainIndices);
                testTable = tableSet.tableForIndices(testIndex);
                
                %grouping
                trainTable.label = labelingStrategy.labelsForClasses(trainTable.label);
                testTable.label = labelingStrategy.labelsForClasses(testTable.label);
                
                %normalisation
                dataNormalizer.fit(trainTable);
                trainTable = dataNormalizer.normalize(trainTable);
                testTable = dataNormalizer.normalize(testTable);
                
                %feature selection
                featureSelector = FeatureSelector();
                %featureSelector.findBestFeaturesForTable(trainTable,obj.nFeatures);
                trainTableReduced = featureSelector.selectFeaturesForTable(trainTable);
                testTableReduced = featureSelector.selectFeaturesForTable(testTable);
                
                %classification
                trainer = Trainer();
                trainer.train(trainTableReduced);
                labels{i} = trainer.test(testTableReduced);
            end
        end
    end
end