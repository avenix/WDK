%returns the FFT
classdef FFT < Computer
    
    methods (Access = public)
        
        function obj = FFT()
            obj.name = 'FFT';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        %receives a fourier transform
        function Y = compute(~,x)
            N = length(x);
            Y = fft(x);
            Y = Y(1:N/2+1);
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            
            n = size(input,1);
            if Helper.IsPowerOf2(n)
                flops = n;
            else
               flops = n * n;
            end
            memory = n;
            outputSize = n/2+1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
