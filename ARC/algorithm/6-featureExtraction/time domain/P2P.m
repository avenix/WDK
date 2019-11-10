classdef P2P < Algorithm
    
    methods (Access = public)
        
        function obj = P2P()
            obj.name = 'P2P';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = peak2peak(signal);
        end
                
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 3 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
