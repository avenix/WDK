%performs leave one subject out cross validation
classdef HoldOutValidator < Algorithm
    properties (Access = public)
        testIndices;
        trainIndices;
        classifier;
        progressNotificationDelegate = [];
        shouldNormalizeFeatures = true;
        featureNormalizer;
    end
    
    methods (Access = public)
        
        function obj = HoldOutValidator()
            obj.name = 'holdOutValidator';
            obj.inputPort = DataType.kTableSet;
            obj.outputPort = DataType.kLabels;
            obj.featureNormalizer = FeatureNormalizer();
        end
        
        function classificationResults = compute(obj,tableSet)
            classificationResults = obj.validate(tableSet);
        end
        
        %returns an instance of ClassificationResult
        function classificationResults = validate(obj,tableSet)
            if isempty(obj.trainIndices) || isempty(obj.testIndices)
                classificationResults = [];
            else
                %train
                trainTable = tableSet.mergedTableForIndices(obj.trainIndices);
                if obj.shouldNormalizeFeatures
                    [validFeatureIdxs, trainTable] = obj.normalizeTrainingTable(trainTable);
                end
                obj.classifier.train(trainTable);
                
                %test
                nTestTables = length(obj.testIndices);
                classificationResults = repmat(ClassificationResult, 1,nTestTables);
                
                for i = 1 : nTestTables
                    testIdx = obj.testIndices(i);
                    testTable = tableSet.mergedTableForIndices(testIdx);
                    
                    if obj.shouldNormalizeFeatures
                        testTable.filterTableToColumns([validFeatureIdxs true]);
                        obj.featureNormalizer.normalize(testTable);
                    end
                    
                    predictedClasses = obj.classifier.test(testTable);
                    classificationResults(i) = ClassificationResult(predictedClasses,testTable);
                end
            end
        end
        
        function str = toString(obj)            
            testIndicesStr = sprintf('[%s]',Helper.ArrayToString(obj.obj.testIndices,','));
            trainIndicesStr = sprintf('[%s]',Helper.ArrayToString(obj.obj.trainIndices,','));
            str = sprintf('%s_%s_%s_%s_%d',obj.name,trainIndicesStr,testIndicesStr,...
                obj.classifier.toString(),obj.shouldNormalizeFeatures);
        end
        
        function editableProperties = getEditableProperties(obj)
            
            testIndicesStr = sprintf('[%s]',Helper.ArrayToString(obj.obj.testIndices,','));
            property1 = Property('testIndices',testIndicesStr);
            property1.type = PropertyType.kArray;
            
            trainIndicesStr = sprintf('[%s]',Helper.ArrayToString(obj.obj.trainIndices,','));
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
            obj.featureNormalizer.normalize(trainTable);
        end
    end
end