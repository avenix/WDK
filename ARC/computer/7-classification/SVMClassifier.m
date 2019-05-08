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
        
        function obj = SVMClassifier(order, boxConstraint)
            if nargin > 0
                obj.order = order;
                obj.boxConstraint = boxConstraint;
            end
            
            obj.name = 'SVM';
            obj.inputPort = ComputerDataType.kTable;
            obj.outputPort = ComputerDataType.kTable;
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
        
        function metrics = computeMetrics(obj,table)
            flops = timeit(@()obj.test(table)) / Constants.kReferenceComputingTime;
            memory = Helper.ComputeObjectSize(obj.classifier);
            outputSize = table.height * Constants.kClassificationResultBytes;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function labels = test(obj,table)
            labels = predict(obj.classifier,table.features);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.order,obj.boxConstraint);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('order',obj.order,1,4,PropertyType.kNumber);
            property2 = Property('boxConstraint',obj.boxConstraint,0,1,PropertyType.kNumber);
            editableProperties = [property1, property2];
        end
    end
end
