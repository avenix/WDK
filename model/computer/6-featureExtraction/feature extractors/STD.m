classdef STD < Computer
    
    methods (Access = public)
        
        function obj = STD()
            obj.name = 'STD';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = std(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 6 * n + 8;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end