classdef Trainer < handle
    
    properties (Access = private)
        classifierTemplate;
        classifier;
    end
    
    methods (Access = public)

        function obj = Trainer()
            obj.classifierTemplate = templateSVM(...
                'KernelFunction', 'polynomial', ...
                'PolynomialOrder', 3, ...
                'KernelScale', 'auto', ...
                'BoxConstraint', 1, ...
                'Standardize', true);
        end
        
        function train(obj,table)
            obj.classifier = fitcecoc(...
                table.features, ...
                table.label, ...
                'Learners', obj.classifierTemplate, ...
                'Coding', 'onevsone');
        end
        
        function labels = test(obj,table)
            labels = predict(obj.classifier,table.features);
        end
    end
end