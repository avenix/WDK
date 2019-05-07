classdef KNNClassifier < Computer
    
    properties (Access = public)
        shouldTrain = false;
        nNeighbors = 10;
        distanceMetric = 'euclidean';
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = KNNClassifier(nNeighbors,distanceMetric)
            if nargin > 0
                obj.nNeighbors = nNeighbors;
                if nargin > 1
                    obj.distanceMetric = distanceMetric;
                end
            end
            
            obj.name = 'KNN';
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
            
            obj.classifier = fitcknn(...
                table.features, ...
                table.label, ...
                'Distance', obj.distanceMetric, ...
                'Exponent', [], ...
                'NumNeighbors', obj.nNeighbors, ...
                'DistanceWeight', 'Equal', ...
                'Standardize', true);
        end
        
        function metrics = computeMetrics(obj,table)
            flops = timeit(@()obj.test(table)) / Constants.kReferenceComputingTime;
            memory = Helper.ComputeObjectSize(obj.classifier);
            outputSize = table.height;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function labels = test(obj,table)
            labels = predict(obj.classifier,table.features);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%s',obj.name,obj.nNeighbors,obj.distanceMetric);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('nNeighbors',obj.nNeighbors,1,100,PropertyType.kNumber);
        end
    end
end
