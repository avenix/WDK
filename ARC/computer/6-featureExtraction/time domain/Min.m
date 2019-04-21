classdef Min < Computer
    
    methods (Access = public)
        
        function obj = Min()
            obj.name = 'Min';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = min(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = n;
            memory = 1;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
