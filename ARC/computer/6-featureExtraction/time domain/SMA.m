%computes the normalized sum of absolute values of signal components
classdef SMA < Computer
    
    methods (Access = public)
        
        function obj = SMA()
            obj.name = 'SMA';
            obj.inputPort = ComputerDataType.kSignalN;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = sum(sum(abs(signal)));
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            m = size(input,2);
            flops = n * m;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
