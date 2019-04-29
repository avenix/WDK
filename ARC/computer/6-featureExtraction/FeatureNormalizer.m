classdef FeatureNormalizer < Computer
    
    properties (Access = public)
        means;
        stds;
        shouldComputeNormalizationValues = false;
    end
    
    methods (Access = public)
        function obj = FeatureNormalizer()    
            obj.name = 'FeatureNormalizer';
            obj.inputPort = ComputerDataType.kTable;
            obj.outputPort = ComputerDataType.kTable;
        end
        
        function fit(obj,table)
            dataArray = table2array(table.features);
            obj.means = mean(dataArray);
            obj.stds = std(dataArray,0,1);
        end
        
        function table = compute(obj,table)
            if obj.shouldComputeNormalizationValues
                obj.fit(table);
                table = [];
            else
                table = obj.normalize(table);
            end
        end
        
        function normalize(obj,table)
            data = table2array(table.table(:,1:end-1));
            N = length(data(:,1));
            normalizedData = data - repmat(obj.means,N,1);
            normalizedData = normalizedData ./ repmat(obj.stds,N,1);
            table.table(:,1:end-1) = array2table(normalizedData);
        end
    end
    
    methods (Access = private)
        function table = eliminateFeaturesAtIndices(obj,table)
            table = table(:,[~obj.constantFeatureIndices true]);
        end
    end
    
    methods (Static)
        function isValidFeatures = ComputeValidFeaturesForTable(table)
            data = table2array(table.features);
            tableStds = std(data,0,1);
            isValidFeatures = ~abs(tableStds < 0.000001);
        end
        
    end
end
