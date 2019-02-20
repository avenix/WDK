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
        
        function obj = KNNClassifier()
            obj.name = 'KNN';
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
            
            obj.classifier = fitcknn(...
                table.features, ...
                table.label, ...
                'Distance', obj.distanceMetric, ...
                'Exponent', [], ...
                'NumNeighbors', obj.nNeighbors, ...
                'DistanceWeight', 'Equal', ...
                'Standardize', true);
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