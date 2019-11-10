%returns the first component of the frequency representation of the signal
classdef SpectralEnergy < Algorithm
    
    methods (Access = public)
        
        function obj = SpectralEnergy()
            obj.name = 'SpectralEnergy';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            N = length(Y);
            pow = Y .* conj(Y);
            result = sum(pow) / N;
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = 1;%power spectrum can be added on the fly
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
