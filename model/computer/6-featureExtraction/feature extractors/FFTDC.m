%returns the first component of the frequency representation of the signal
classdef FFTDC < Computer
    
    properties (Access = public)
        fourierTransform;
    end
    
    methods (Access = public)
        
        function obj = FFTDC()
            obj.name = 'FFTDC';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(obj,signal)
            localFourierTransform = obj.fourierTransform;
            
            %if isempty(localFourierTransform)
                %localFourierTransform = fft(signal);%this is probably wrong, should be tested
            %end
            
            Y = optimizedFFT(signal,localFourierTransform);
            result = real(Y(1));
        end
    end
end