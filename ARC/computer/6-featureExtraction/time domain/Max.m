classdef Max < Computer
    
    methods (Access = public)
        
        function obj = Max()
            obj.name = 'Max';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = max(signal);
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
