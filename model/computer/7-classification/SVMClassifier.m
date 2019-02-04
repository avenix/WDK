classdef SVMClassifier < Computer
    
    properties (Access = public)
        order = 3;
        boxConstraint = 1;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = SVMClassifier()
            obj.name = 'SVM';
        end
        
        function dataOut = compute(obj,data)
            dataOut = obj.test(data);
        end
        
        function train(obj,table)
            classifierTemplate = templateSVM(...
                'KernelFunction', 'polynomial', ...
                'PolynomialOrder', obj.order, ...
                'KernelScale', 'auto', ...
                'BoxConstraint', obj.boxConstraint, ...
                'Standardize', true);
            
            obj.classifier = fitcecoc(...
                table.features, ...
                table.label, ...
                'Learners', classifierTemplate, ...
                'Coding', 'onevsone');
        end
        
        function labels = test(obj,table)
            labels = predict(obj.classifier,table.features);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.order,obj.boxConstraint);
        end
    end
end