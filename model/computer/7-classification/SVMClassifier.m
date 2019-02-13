classdef SVMClassifier < Computer
    
    properties (Access = public)
        order = 1;
        boxConstraint = 1;
        shouldTrain = false;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = SVMClassifier()
            obj.name = 'SVM';
            obj.inputPort = ComputerPort(ComputerPortType.kTable);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
        end
        
        function dataOut = compute(obj,data)
            if obj.shouldTrain
                obj.train(data);
                dataOut = [];
            else
                dataOut = obj.test(data);
            end
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
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('order',obj.order);
            property2 = Property('boxConstraint',obj.boxConstraint);
            editableProperties = [property1, property2];
        end
    end
end