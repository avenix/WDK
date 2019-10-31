classdef Subtractor < Computer
    
    methods (Access = public)
        
        function obj = Subtractor()
            obj.name = 'subtractor';
            obj.inputPort = DataType.kSignal2;
            obj.outputPort = DataType.kSignal;
        end
        
        function computedSignal = compute(~,dataIn)
            computedSignal = dataIn(:,1) - dataIn(:,2);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = n;
            outputSize = n;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
