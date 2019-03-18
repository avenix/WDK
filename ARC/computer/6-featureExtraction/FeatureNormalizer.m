classdef FeatureNormalizer < Computer
    
    properties (Access = public)
        means;
        stds;
    end
    
    methods (Access = public)
        function obj = FeatureNormalizer()    
            obj.name = 'FeatureNormalizer';
            obj.inputPort = ComputerPort(ComputerPortType.kTable);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
        end
        
        function fit(obj,table)
            dataArray = table2array(table.features);
            obj.means = mean(dataArray);
            obj.stds = std(dataArray,0,1);
        end
        
        function table = compute(obj,table)
            table = obj.normalize(table);
        end
        
        function table = normalize(obj,table)
            table = table.table;
            data = table2array(table(:,1:end-1));
            N = length(data(:,1));
            normalizedData = data - repmat(obj.means,N,1);
            normalizedData = normalizedData ./ repmat(obj.stds,N,1);
            table(:,1:end-1) = array2table(normalizedData);
            table = Table(table);
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