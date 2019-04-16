classdef Variance < Computer
    
    methods (Access = public)
        
        function obj = Variance()
            obj.name = 'Variance';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = var(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 6 * n + 4;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
