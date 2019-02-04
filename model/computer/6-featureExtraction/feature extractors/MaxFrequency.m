classdef MaxFrequency < Computer
    properties (Access = public)
        fourierTransform;
    end
    
    methods (Access = public)
        
        function obj = MaxFrequency()
            obj.name = 'MaxFrequency';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kNx2);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            
            localFourierTransform = obj.fourierTransform;
            
            %if isempty(localFourierTransform)
            %localFourierTransform = fft(signal);%this is probably wrong, should be tested
            %end
            
            signalLength = length(signal);
            Fs = 1000;
            frequency = Fs*(0:(signalLength/2))/signalLength;
            endIndex = round(signalLength / 2 + 1);
            
            P2 = abs(optimizedFFT(signal,localFourierTransform)/signalLength);
            P1 = P2(1:endIndex);
            P1(2:end-1) = 2*P1(2:end-1);
            [~, maxIndex] = max(P1);
            result = frequency(maxIndex);
        end
    end
end