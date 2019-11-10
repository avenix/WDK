classdef MAD < Algorithm
    
    methods (Access = public)
        
        function obj = MAD()
            obj.name = 'MAD';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = mad(signal);
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
