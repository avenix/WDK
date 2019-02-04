%returns the first component of the frequency representation of the signal
classdef SpectralEntropy < Computer
    
    properties (Access = public)
        fourierTransform;
    end
    
    methods (Access = public)
        
        function obj = SpectralEntropy()
            obj.name = 'SpectralEntropy';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(obj,signal)
            
            localFourierTransform = obj.fourierTransform;
            
            %if isempty(localFourierTransform)
            %localFourierTransform = fft(signal);%this is probably wrong, should be tested
            %end
            
            powerSpectrumResult = powerSpectrum(signal,localFourierTransform);
            
            %Normalization
            maxPower = sum(powerSpectrumResult + 1e-12);
            powerSpectrumResult = powerSpectrumResult / maxPower;
            
            %entropy calculation
            result = -sum(powerSpectrumResult.*log2(powerSpectrumResult+eps));
        end
    end
end
