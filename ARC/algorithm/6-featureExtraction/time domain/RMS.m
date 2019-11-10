classdef RMS < Algorithm
    
    methods (Access = public)
        
        function obj = RMS()
            obj.name = 'RMS';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        function dataOut = compute(~,signal)
            dataOut = rms(signal);
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
