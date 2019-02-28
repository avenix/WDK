classdef Quantile < Computer
    properties (Access = public)
        numQuantileParts;
    end
    
    methods (Access = public)
        
        function obj = Quantile(numQuantileParts)
            if nargin > 0
                obj.numQuantileParts = numQuantileParts;
            end
            obj.name = 'Quantile';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(obj,data)
            result = quantile(data,obj.numQuantileParts);
        end
        
        function str = toString(obj)
            str = sprintf('quantile%d',obj.numQuantileParts);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = Property('numQuantileParts',obj.numQuantileParts);
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            flops = 2 * n * log(n);
            memory = 4 * obj.numQuantileParts;
            outputSize = 4 * obj.numQuantileParts;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end