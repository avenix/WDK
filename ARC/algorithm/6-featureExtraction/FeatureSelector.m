classdef FeatureSelector < Algorithm
    properties (Access = public)
         selectedFeatureIdxs = [38, 30, 22, 33, 12, 35, 26, 39, 20, 36, 27,...
             32, 25, 29, 24, 21, 23, 10, 31, 1, 9, 41, 37, 18, 2, 28, 40,...
             34, 17, 45, 19, 8, 42, 7, 11, 14, 3, 16, 4, 13];
    end
    
    methods (Access = public)
        function obj =  FeatureSelector()
            obj.name = 'FeatureSelector';
            obj.inputPort = DataType.kTable;
            obj.outputPort = DataType.kTable;
        end
        
        function table = compute(obj,table)
            table = obj.selectFeaturesForTable(table);
        end
        
        function table = selectFeaturesForTable(obj,table)
             table.filterTableToColumns([obj.selectedFeatureIdxs table.width]);
        end
        
        %discretizedPredictors will crash if the table contained NaN values
        %or if every instance had the same value on the same feature
        function findBestFeaturesForTable(obj, table, nFeatures)
            nFeatures = min(table.width - 1, nFeatures);
            
            predictors = table2array(table.features);
            predictors = obj.discretizedPredictors(predictors,table.columnNames);
            predictors = predictors(:,predictors(1,:) >= 0);
            responses = table.label-1;
            
            obj.selectedFeatureIdxs = mrmr_mid_d(predictors, responses, nFeatures);
        end
        
        function bestFeatures = getBestNFeatures(obj, n)
            n = min(n,length(obj.selectedFeatureIdxs));
            bestFeatures = obj.selectedFeatureIdxs(1:n);
        end
    end
    
    methods (Access = private)
        
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
