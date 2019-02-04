classdef PowerSpectrum < Computer
    properties (Access = public)
        fourierTransform;
    end
    
    methods (Access = public)
        
        function obj = PowerSpectrum()
            obj.name = 'Skewness';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            
            localFourierTransform = obj.fourierTransform;
            
            %if isempty(localFourierTransform)
            %localFourierTransform = fft(signal);%this is probably wrong, should be tested
            %end
            
            N = length(signal);
            Y = optimizedFFT(signal,localFourierTransform);
            
            result = ((sqrt(abs(Y).*abs(Y)) * 2 )/N);
            result = result(1:floor(N/2));
        end
    end
    
end