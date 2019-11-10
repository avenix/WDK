classdef TreeClassifier < Algorithm
    
    properties (Access = public)
        shouldTrain = false;
        maxNumSplits = 100;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = TreeClassifier(maxNumSplits)
            if nargin > 0
                obj.maxNumSplits = maxNumSplits;
            end
            obj.name = 'Tree';
            obj.inputPort = DataType.kTable;
            obj.outputPort = DataType.kTable;
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
            obj.classifier = fitctree(...
                table.features, ...
                table.label, ...
                'SplitCriterion', 'gdi', ...
                'MaxNumSplits', obj.maxNumSplits, ...
                'Surrogate', 'off');
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
            str = sprintf('%s_%d',obj.name,obj.maxNumSplits);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('maxNumSplits',obj.maxNumSplits,1,100,PropertyType.kNumber);
        end
    end
end
