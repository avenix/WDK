%performs leave one subject out cross validation
classdef LeaveOneOutCrossValidator < handle
    properties (Access = public)
        nFeatures = 20;
        shouldNormalizeFeatures = false;
        classifier;
        tableSet;
    end
    
    properties (Access = private)
        dataNormalizer;
    end
    
    methods (Access = public)
        
        function obj = LeaveOneOutCrossValidator()
            obj.dataNormalizer = FeatureNormalizer();
        end
        
        function truthLabels = getTruthLabels(obj)
            truthLabels = obj.tableSet.getAllLabels();
        end
        
        %receives a table set, cross validates and
        %returns a cell array with an array of labels in each cell
        function labels = validate(obj)
            
            nTables = obj.tableSet.nTables;
            labels = cell(1,nTables);
            
                
            waitBar = waitbar(0,'Validating...');
                
            for i = 1 : nTables
                trainIndices = [1 : i-1, i+1 : nTables];
                testIndex = i;
                
                trainTable = obj.tableSet.mergedTableForIndices(trainIndices);
                testTable = obj.tableSet.mergedTableForIndices(testIndex);
                
                waitBarMsg = sprintf('Validating fold %s ...',testIndex);
                waitbar(i/nTables,waitBar,waitBarMsg);
                
                %normalisation
                if(obj.shouldNormalizeFeatures)
                    obj.dataNormalizer.fit(trainTable);
                    trainTable = obj.dataNormalizer.normalize(trainTable);
                    testTable = obj.dataNormalizer.normalize(testTable);
                end
                
                %classification
                obj.classifier.train(trainTable);
                labels{i} = obj.classifier.test(testTable);
            end
            
            close(waitBar);
            
            labels = cat(1,labels{:});
        end
    end
end