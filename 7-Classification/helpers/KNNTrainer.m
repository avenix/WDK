classdef KNNTrainer < handle
    methods
        
        function [trainedClassifier, validationAccuracy] = train(obj,trainingData)
            
            inputTable = trainingData;
            predictors = inputTable(:,1:end-1);
            response = inputTable.label;
            
            % Train a classifier
            % This code specifies all the classifier options and trains the classifier.
            classificationKNN = fitcknn(...
                predictors, ...
                response, ...
                'Distance', 'Euclidean', ...
                'Exponent', [], ...
                'NumNeighbors', 1, ...
                'DistanceWeight', 'Equal', ...
                'Standardize', true, ...
                'ClassNames', [1; 2; 3; 4; 5; 6; 7; 8]);
            
            % Create the result struct with predict function
            predictorExtractionFcn = @(t) t(:,1:end-1);
            knnPredictFcn = @(x) predict(classificationKNN, x);
            trainedClassifier.predictFcn = @(x) knnPredictFcn(predictorExtractionFcn(x));
            
            % Add additional fields to the result struct
            trainedClassifier.RequiredVariables = {'maxGx', 'stdGz', 'quantileAz2', 'zrcAy', 'meanGx_PH', 'rmsGx', 'corrAyAz', 'stdAx', 'quantileAz3', 'maxAy', 'smaRotation', 'corrAyGx', 'quantileGx1', 'quantileGx3', 'meanAz_SH', 'stdGx', 'meanAy_PH', 'rmsGz', 'aavAx', 'meanGx_FH', 'madGx', 'skewnessGx', 'maxGz', 'rmsAz', 'quantileAy3', 'meanAz_FH', 'meanAz_PH', 'AccPeaks_SH', 'zrcGx', 'madAx'};
            trainedClassifier.ClassificationKNN = classificationKNN;
            trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2018a.';
            trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');
            
            % Extract predictors and response
            % This code processes the data into the right shape for training the
            % model.
            inputTable = trainingData;
            predictorNames = {'maxGx', 'stdGz', 'quantileAz2', 'zrcAy', 'meanGx_PH', 'rmsGx', 'corrAyAz', 'stdAx', 'quantileAz3', 'maxAy', 'smaRotation', 'corrAyGx', 'quantileGx1', 'quantileGx3', 'meanAz_SH', 'stdGx', 'meanAy_PH', 'rmsGz', 'aavAx', 'meanGx_FH', 'madGx', 'skewnessGx', 'maxGz', 'rmsAz', 'quantileAy3', 'meanAz_FH', 'meanAz_PH', 'AccPeaks_SH', 'zrcGx', 'madAx'};
            
            % Perform cross-validation
            partitionedModel = crossval(trainedClassifier.ClassificationKNN, 'KFold', 5);
            
            % Compute validation predictions
            [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
            
            % Compute validation accuracy
            validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
        end
    end
end
