classdef FeatureSelector < handle
    properties (Access = public)
         selectedFeatureIdxs = [58, 278, 119, 292, 16, 59, 5, 37, 155, 17, 56, 121, 215, 142, 35, 251, 167, 133, 13, 38];
    end
    
    methods (Access = public)
        
        function obj = FeatureSelector()
        end

        function selectFeaturesForTable(obj,table)
             table.filterTableToColumns([obj.selectedFeatureIdxs table.width]);
        end
        
        %discretizedPredictors will crash if the table contained NaN values
        %or if every instance had the same value on the same feature
        function findBestFeaturesForTable(obj, table, maxNFeatures)
            maxNFeatures = min(table.width - 1, maxNFeatures);
            
            predictors = table2array(table.features);
            predictors = obj.discretizedPredictors(predictors,table.columnNames);
            predictors = predictors(:,predictors(1,:) >= 0);
            responses = table.label-1;
            
            obj.selectedFeatureIdxs = mrmr_mid_d(predictors, responses, maxNFeatures);
        end
        
        function bestFeatures = getBestNFeatures(obj, n)
            n = min(n,length(obj.selectedFeatureIdxs));
            bestFeatures = obj.selectedFeatureIdxs(1:n);
        end
        
        function printFeatures(~, selectedFeatureIndices, featureNames)
            %print feature list as strings
            fprintf('Best features are:\n');
            for i = 1 : length(selectedFeatureIndices)
                featureIdx = selectedFeatureIndices(i);
                featureName = featureNames(featureIdx);
                fprintf('%d %s\n',featureIdx,featureName{1});
            end
        end
        
        %print feature list to copy into your code
        function printFeatureIndices(~,selectedFeatureIndices)
            for i = 1 : length(selectedFeatureIndices)
                fprintf('%d, ',selectedFeatureIndices(i));
            end
        end
        
    end
    
    methods (Access = private)
        
        function printFeaturesAndCounts(~,featureIdxs,featureCounts,featureNames)
            
            fprintf('Feature;Count\n');
            %for i = 1 : length(featureIdxs)
            for i = 1 : 20
                featureIdx = featureIdxs(i);
                featureName = featureNames(featureIdx);
                fprintf('%s;%d\n',featureName{1},featureCounts(i));
            end
        end
        
        %discretize predictors into categories
        function predictors = discretizedPredictors(~,predictors,featureNames)
            alpha = 1;
            for i = 1 : size(predictors,2)
                m = mean(predictors(:,i));
                dev = std(predictors(:,i));
                firstEdge = min(predictors(:,i));
                lastEdge = max(predictors(:,i));
                edges = [firstEdge,m-alpha*dev, m+alpha*dev,lastEdge];
                edges = sort(edges);
                
                if isnan(edges)
                    
                    fprintf('%s,%d - %s\n',Constants.kConstantFeaturesWarning, i,featureNames{i});
                    predictors(:,i) = -1;
                else
                    predictors(:,i) = discretize(predictors(:,i),edges);
                end
            end
        end
        
        function labels = makeLabelsContinuous(~, labels)
            m = containers.Map('KeyType','int32','ValueType','int32');
            
            labelCount = 0;
            
            for i = 1 : length(labels)
                currentLabel = labels(i);
                if ~isKey(m,currentLabel)
                    m(currentLabel) = labelCount;
                    labelCount = labelCount + 1;
                end
            end
            
            for i = 1 : length(labels)
                currentLabel = labels(i);
                labels(i) = m(currentLabel);
            end
            
        end
        
    end
end
