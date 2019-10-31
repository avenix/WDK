classdef Min < Computer
    
    methods (Access = public)
        
        function obj = Min()
            obj.name = 'Min';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = min(signal);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
