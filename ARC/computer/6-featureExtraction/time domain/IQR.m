classdef IQR < Computer
    
    methods (Access = public)
        
        function obj = IQR()
            obj.name = 'IQR';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = iqr(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 57 * n;
            memory = n;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
