classdef STD < Computer
    
    methods (Access = public)
        
        function obj = STD()
            obj.name = 'STD';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = std(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = 1;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
