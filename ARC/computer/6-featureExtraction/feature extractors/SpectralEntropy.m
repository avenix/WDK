%returns the first component of the frequency representation of the signal
classdef SpectralEntropy < Computer
   
    methods (Access = public)
        
        function obj = SpectralEntropy()
            obj.name = 'SpectralEntropy';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)

            powerSpectrumResult = powerSpectrum(Y);
            
            %Normalization
            sumPower = sum(powerSpectrumResult + 1e-12);
            powerSpectrumResult = powerSpectrumResult / sumPower;
            
            %entropy calculation
            result = -sum(powerSpectrumResult.*log2(powerSpectrumResult+eps));
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
