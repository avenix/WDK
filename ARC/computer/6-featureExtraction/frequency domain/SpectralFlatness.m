%returns the first component of the frequency representation of the signal
classdef SpectralFlatness < Computer
   
    methods (Access = public)
        
        function obj = SpectralFlatness()
            obj.name = 'SpectralFlatness';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            pxx = periodogram(Y);
            num = geomean(pxx);
            den = mean(pxx);
            result = num / den;
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 68 * n;
            memory = n;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
