%returns the frequency band with highest value
classdef MaxFrequency < Algorithm
    
    methods (Access = public)
        
        function obj = MaxFrequency()
            obj.name = 'MaxFrequency';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            [~, result] = max(Y);
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
