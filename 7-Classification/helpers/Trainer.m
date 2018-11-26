classdef Trainer < handle
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        function obj = Trainer()
            %obj.testTrainer();
            
        end
        
        function testTrainer(obj)
            
            tableImporter = TableImporter();
            table = tableImporter.importTable('featuresTable.txt');
            predictors = table(1:end,1:end-1);
            response = table(1:end,end);
            obj.train(predictors,response);
        end
        
        function train(obj,table)
            predictors = table(:,1:end-1);
            response = table(:,end);
            template = templateSVM(...
                'KernelFunction', 'polynomial', ...
                'PolynomialOrder', 3, ...
                'KernelScale', 'auto', ...
                'BoxConstraint', 1, ...
                'Standardize', true);
            obj.classifier = fitcecoc(...
                predictors, ...
                response, ...
                'Learners', template, ...
                'Coding', 'onevsone');
            
            % Create the result struct with predict function
            %predictorExtractionFcn = @(t) t(:, predictorNames);
            %svmPredictFcn = @(x) predict(obj.classifier, x);
            %obj.classifier.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));
        end
        
        function labels = test(obj,table)
            predictors = table(:,1:end-1);
            labels = predict(obj.classifier,predictors);
        end
    end
end