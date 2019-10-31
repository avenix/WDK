classdef Median < Computer
    
    methods (Access = public)
        
        function obj = Median()
            obj.name = 'Median';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = median(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 15 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
