%returns the first component of the frequency representation of the signal
classdef FFTDC < Computer
    
    properties (Access = public)
        fourierTransform;
    end
    
    methods (Access = public)
        
        function obj = FFTDC()
            obj.name = 'FFTDC';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
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
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = n * log2(n) + n;
            memory = n;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end