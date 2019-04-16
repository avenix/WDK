%returns the first component of the frequency representation of the signal
classdef FFTDC < Computer
    
    methods (Access = public)
        
        function obj = FFTDC()
            obj.name = 'FFTDC';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
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
