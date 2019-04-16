classdef MaxFrequency < Computer
    
    methods (Access = public)
        
        function obj = MaxFrequency()
            obj.name = 'MaxFrequency';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
                        
            signalLength = length(Y);
            Fs = 1000;
            frequency = Fs*(0:(signalLength/2))/signalLength;
            endIndex = round(signalLength / 2 + 1);
            
            P2 = abs(Y/signalLength);
            P1 = P2(1:endIndex);
            P1(2:end-1) = 2*P1(2:end-1);
            [~, maxIndex] = max(P1);
            result = frequency(maxIndex);
        end

        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n * log(n) + 2 * n;
            memory = n;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
