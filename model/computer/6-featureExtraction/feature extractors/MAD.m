classdef MAD < Computer
    
    methods (Access = public)
        
        function obj = MAD()
            obj.name = 'MAD';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = mad(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 5 * n + 10;
            memory = 4 * (n + 7);
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end