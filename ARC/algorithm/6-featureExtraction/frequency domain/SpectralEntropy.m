%returns the first component of the frequency representation of the signal
classdef SpectralEntropy < Algorithm
    
    methods (Access = public)
        
        function obj = SpectralEntropy()
            obj.name = 'SpectralEntropy';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        %receives a power spectrum
        function result = compute(~,powerSpectrum)
            
            %Normalization
            sumPower = sum(powerSpectrum + 1e-12);
            powerSpectrum = powerSpectrum / sumPower;
            
            %entropy calculation
            result = -sum(powerSpectrum .* log2(powerSpectrum+eps));
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 21 * n;
            memory = n * 4;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
