classdef Mean < Computer
    
    methods (Access = public)
        
        function obj = Mean()
            obj.name = 'Mean';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = mean(signal);
        end

        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 3 * n + 2;
            memory = 8;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end