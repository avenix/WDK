classdef Max < Computer
    
    methods (Access = public)
        
        function obj = Max()
            obj.name = 'Max';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = max(signal);
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
