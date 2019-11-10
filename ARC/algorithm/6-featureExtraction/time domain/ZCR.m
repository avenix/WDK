classdef ZCR < Algorithm
    
    methods (Access = public)
        
        function obj = ZCR()
            obj.name = 'ZCR';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function result = compute(~,signal)
            N = length(signal);
            result = sum(abs(diff(signal>0))) / N;
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 5 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
