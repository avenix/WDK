%performs leave one subject out cross validation
classdef LeaveOneOutCrossValidator < Computer
    properties (Access = public)
        classifier;
        shouldNormalizeFeatures = false;
        progressNotificationDelegate = [];
    end
    
    properties (Access = private)
        featureNormalizer;
    end
    
    methods (Access = public)
        
        function obj = LeaveOneOutCrossValidator(classifier)
            if nargin > 0
                obj.classifier = classifier;
            end
            
            obj.featureNormalizer = FeatureNormalizer();
            
            obj.name = 'leaveOneOutValidator';
            obj.inputPort = ComputerDataType.kTableSet;
            obj.outputPort = ComputerDataType.kLabels;
        end
        
        function classificationResults = compute(obj,tableSet)
            classificationResults = obj.validate(tableSet);
        end
        
        %receives a table set, cross validates and
        %returns a cell array with an array of labels in each cell
        function classificationResults = validate(obj,tableSet)
            
            nTables = tableSet.nTables;
            
            classificationResults = repmat(ClassificationResult, 1,nTables);
            
            if ~isempty(obj.progressNotificationDelegate)
                obj.progressNotificationDelegate.handleValidationStarted();
            end
            
            for testIndex = 1 : nTables
                trainIndices = [1 : testIndex-1, testIndex+1 : nTables];
                
                trainTable = tableSet.mergedTableForIndices(trainIndices);
                testTable = tableSet.mergedTableForIndices(testIndex);
                
                if ~isempty(obj.progressNotificationDelegate)
                    obj.progressNotificationDelegate.handleValidationProgress(testIndex,nTables);
                end
                
                %normalisation
                if(obj.shouldNormalizeFeatures)
                    obj.featureNormalizer.fit(trainTable);
                    obj.featureNormalizer.normalize(trainTable);
                    obj.featureNormalizer.normalize(testTable);
                end
                
                %classification
                obj.classifier.train(trainTable);                
                
                %truthClasses = tableSet.labelsAtIndex(testIndex);
                predictedClasses = obj.classifier.test(testTable);
                classificationResults(testIndex) = ClassificationResult(predictedClasses,testTable);
            end
            
            if ~isempty(obj.progressNotificationDelegate)
                obj.progressNotificationDelegate.handleValidationFinished();
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s_%d',obj.name,obj.classifier.toString(),obj.shouldNormalizeFeatures);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('shouldNormalizeFeatures',obj.shouldNormalizeFeatures,false,true,PropertyType.kBoolean);
        end
    end
end