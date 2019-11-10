classdef Energy < Algorithm
    
    methods (Access = public)
        
        function obj = Energy()
            obj.name = 'Energy';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = sum(signal.^2);
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
