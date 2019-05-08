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
            flops = 2 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
