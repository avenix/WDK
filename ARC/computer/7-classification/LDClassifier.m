classdef LDClassifier < Computer
    
    properties (Access = public)
        shouldTrain = false;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = LDClassifier()
            obj.name = 'LinearDiscriminant';
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
            
            obj.classifier = fitcdiscr(...
                table.features, ...
                table.label, ...
                'DiscrimType', 'linear', ...
                'Gamma', 0, ...
                'FillCoeffs', 'off');
        end
        
        function labels = test(obj,table)
            labels = predict(obj.classifier,table.features);
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
    end
end