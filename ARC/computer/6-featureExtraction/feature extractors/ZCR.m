classdef ZCR < Computer
    
    methods (Access = public)
        
        function obj = ZCR()
            obj.name = 'ZCR';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            N = length(signal);
            result = sum(abs(diff(signal>0))) / N;
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 7 * n + 1;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
