classdef Median < Computer
    
    methods (Access = public)
        
        function obj = Median()
            obj.name = 'Median';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = median(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 5 * n;%medians of medians computes median in O(n) time
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end