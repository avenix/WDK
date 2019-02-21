classdef Min < Computer
    
    methods (Access = public)
        
        function obj = Min()
            obj.name = 'Min';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = min(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end