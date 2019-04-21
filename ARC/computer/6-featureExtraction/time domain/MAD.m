classdef MAD < Computer
    
    methods (Access = public)
        
        function obj = MAD()
            obj.name = 'MAD';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = mad(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 5 * n;
            memory = 1;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end
