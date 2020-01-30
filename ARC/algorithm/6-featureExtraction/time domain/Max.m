classdef Max < Algorithm
    
    methods (Access = public)
        
        function obj = Max()
            obj.name = 'Max';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = max(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 1 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
