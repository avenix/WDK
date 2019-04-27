%performs leave one subject out cross validation
classdef HoldOutValidator < Computer
    properties (Access = public)
        testIndices;
        trainIndices;
        classifier;
        shouldNormalizeFeatures = true;
        progressNotificationDelegate;
    end

    properties (Access = private)
        featureNormalizer;
    end
    
    methods (Access = public)
        
        function obj = HoldOutValidator()
            obj.name = 'holdOutValidator';
            obj.inputPort = ComputerDataType.kTableSet;
            obj.outputPort = ComputerDataType.kLabels;
            obj.featureNormalizer = FeatureNormalizer();
        end
        
        function labels = compute(obj,tableSet)
            labels = obj.validate(tableSet);
        end
        
        function labels = validate(obj,tableSet)
            if isempty(obj.trainIndices) || isempty(obj.testIndices)
                labels = {};
            else
                
                %train
                trainTable = tableSet.mergedTableForIndices(obj.trainIndices);
                if obj.shouldNormalizeFeatures
                    [validFeatureIdxs, trainTable] = obj.normalizeTrainingTable(trainTable);
                end
                obj.classifier.train(trainTable);
                
                %test
                nTestTables = length(obj.testIndices);
                labels = cell(1,nTestTables);
                for i = 1 : nTestTables
                    testIdx = obj.testIndices(i);
                    testTable = tableSet.mergedTableForIndices(testIdx);
                    
                    if obj.shouldNormalizeFeatures
                        testTable.filterTableToColumns([validFeatureIdxs true]);
                        testTable = obj.featureNormalizer.normalize(testTable);
                    end
                    
                    labels{i} = obj.classifier.test(testTable);
                end
            end
        end
        
        function str = toString(obj)            
            testIndicesStr = sprintf('[%s]',Helper.arrayToString(obj.obj.testIndices,','));
            trainIndicesStr = sprintf('[%s]',Helper.arrayToString(obj.obj.trainIndices,','));
            str = sprintf('%s_%s_%s_%s_%d',obj.name,trainIndicesStr,testIndicesStr,...
                obj.classifier.toString(),obj.shouldNormalizeFeatures);
        end
        
        function editableProperties = getEditableProperties(obj)
            
            testIndicesStr = sprintf('[%s]',Helper.arrayToString(obj.obj.testIndices,','));
            property1 = Property('testIndices',testIndicesStr);
            property1.type = PropertyType.kArray;
            
            trainIndicesStr = sprintf('[%s]',Helper.arrayToString(obj.obj.trainIndices,','));
            property2 = Property('trainIndices',trainIndicesStr);
            property2.type = PropertyType.kArray;
            
            property3 = Property('shouldNormalizeFeatures',obj.shouldNormalizeFeatures,false,true,PropertyType.kBoolean);
            
            editableProperties = [property1,property2,property3];
        end
        
    end
    methods (Access = private)
        function [validFeatureIdxs, trainTable] = normalizeTrainingTable(obj,trainTable)
            validFeatureIdxs = FeatureNormalizer.ComputeValidFeaturesForTable(trainTable);
            trainTable.filterTableToColumns([validFeatureIdxs true]);
            obj.featureNormalizer.fit(trainTable);
            trainTable = obj.featureNormalizer.normalize(trainTable);
        end
    end
end