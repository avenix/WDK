classdef DataNormalizer < handle
    
    properties
        means;
        stds;
        constantFeatureIndices;
    end
    
    methods (Access = public)
        function obj = DataNormalizer()
        end
        
        function fitDefaultValues(obj)
            obj.means = single([-0.278018300221995,0.0923631801787675,-0.0532889137694098,1109.41207553265,-0.518758940614599,-0.0699023747615921,-6.40977239525958,0.037762279581652,1.02903056080922,-0.523731333236072,-0.0508155481480647,-0.296077909905216,3.98574916986171,-22.5928940787791,0.338819173237377,4.02491935204604,20.1469033227663,56.3174302838361,-0.243821573296115,0.361335828312989]);
            obj.stds = single([0.487362127108864,0.0642799864321603,0.570252407516065,571.058740537843,0.477614737111238,0.492878713255037,6.25848871130343,0.485473845014048,0.538382446794117,0.499638047113641,0.535760834704015,0.504125062410891,2.88059532300775,39.5412204887456,0.584853933266395,1.88117059660365,10.6610075271704,114.071008808235,0.571897036246548,0.518127144670645]);
        end
        
        function fit(obj,table)
            data = table2array(table(:,1:end-1));
            obj.means = mean(data);
            obj.stds = std(data,0,1);
            obj.constantFeatureIndices = abs(obj.stds < 0.000001);
        end
        
        function table = normalize(obj,table)
            if ~isempty(obj.constantFeatureIndices)
                table = obj.eliminateFeaturesAtIndices(table);
            end
            
            data = table2array(table(:,1:end-1));
            N = length(data(:,1));
            normalizedData = data - repmat(obj.means,N,1);
            normalizedData = normalizedData ./ repmat(obj.stds,N,1);
            table(:,1:end-1) = array2table(normalizedData);
        end
    end
    
    methods (Access = private)
        function table = eliminateFeaturesAtIndices(obj,table)
            table = table(:,[~obj.constantFeatureIndices true]);
        end
    end
end