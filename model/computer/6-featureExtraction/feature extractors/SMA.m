classdef SMA < Computer
    
    methods (Access = public)
        
        function obj = SMA()
            obj.name = 'SMA';
            obj.inputPort = ComputerPort(ComputerPortType.kSignalN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(sum(abs(signal)));
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            m = size(input,2);
            flops = 3 * n * m;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end