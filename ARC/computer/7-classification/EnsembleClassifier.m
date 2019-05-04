classdef EnsembleClassifier < Computer
        
    properties (Access = public)
        shouldTrain = false;
        nLearners = 30;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = EnsembleClassifier()
            obj.name = 'Ensemble';
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
            
            template = templateTree(...
                'MaxNumSplits', 1852);
            
            if ~isempty(template)
                obj.classifier = fitcensemble(...
                    table.features, ...
                    table.label, ...
                    'Method', 'Bag', ...
                    'NumLearningCycles', obj.nLearners, ...
                    'Learners', template);
            end
        end
        
        function metrics = computeMetrics(obj,input)
            flops = timeit(@()obj.test(input)) / Constants.kReferenceComputingTime;
            memory = Helper.ComputeObjectSize(obj.classifier);
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function labels = test(obj,table)
            labels = predict(obj.classifier,table.features);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.nLearners);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('nLearners',obj.nLearners,1,100,PropertyType.kNumber);
        end
    end
end
