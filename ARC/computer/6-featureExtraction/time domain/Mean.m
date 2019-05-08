classdef Mean < Computer
    
    methods (Access = public)
        
        function obj = Mean()
            obj.name = 'Mean';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = mean(signal);
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
