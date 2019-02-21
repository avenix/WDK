%returns the first component of the frequency representation of the signal
classdef SpectralFlatness < Computer
   
    methods (Access = public)
        
        function obj = SpectralFlatness()
            obj.name = 'SpectralFlatness';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            pxx = periodogram(signal);
            num = geomean(pxx);
            den = mean(pxx);
            result = num / den;
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n * log(n) + 7 * n;
            memory = n * 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end