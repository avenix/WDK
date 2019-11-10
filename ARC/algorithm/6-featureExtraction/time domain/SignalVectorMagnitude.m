classdef SignalVectorMagnitude < Algorithm
    
    methods (Access = public)
        
        function obj = SignalVectorMagnitude()
            obj.name = 'SignalVectorMagnitude';
            obj.inputPort = DataType.kSignal2;
            obj.outputPort = DataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = sum(sqrt(signal(:,1).^2 + signal(:,2).^2)) / size(signal,1);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
