classdef TreeClassifier < Computer
    
    properties (Access = public)
        shouldTrain = false;
        maxNumSplits = 100;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = TreeClassifier()
            obj.name = 'Tree';
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
            
            obj.classifier = fitctree(...
                table.features, ...
                table.label, ...
                'SplitCriterion', 'gdi', ...
                'MaxNumSplits', obj.maxNumSplits, ...
                'Surrogate', 'off');
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