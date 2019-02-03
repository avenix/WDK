classdef FeatureNormalizer < handle
    
    properties (Access = public, Constant)
        kDefaultMeanNormalizationValues = single([-0.171875006639446,0.0468303847813437,0.0590290343468064,1508.55850629509,-0.64514486369421,-0.0618635351528421,-4.47171894526393,0.243406630783123,0.448676680776663,-0.646126091926657,0.0704961015559272,-0.150637408439861,3.0086163094071,-33.9570933342951,0.636217761265573,3.84007871696414,7.85058079926725,71.9829594851307,-0.155279844229983,0.500101494326892]);
        kDefaultStdNormalizationValues = single([0.304976229488623,0.0445774373829834,0.511246558639433,657.555968965648,0.317487215166105,0.412535254582878,5.55030609771675,0.371774681985852,0.378329045809977,0.408197154484431,0.444145160437692,0.362326999147572,1.96785458260744,60.4565867228209,0.4474209920147,2.64986024727632,7.50393151316385,102.740505504019,0.596244809804285,0.472711779281237]);
    end
    
    properties
        means;
        stds;
    end
    
    methods (Access = public)
        function fitDefaultValues(obj)
            obj.means = FeatureNormalizer.kDefaultMeanNormalizationValues;
            obj.stds = FeatureNormalizer.kDefaultStdNormalizationValues;
        end
        
        function fit(obj,table)
            dataArray = table2array(table.features);
            obj.means = mean(dataArray);
            obj.stds = std(dataArray,0,1);
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