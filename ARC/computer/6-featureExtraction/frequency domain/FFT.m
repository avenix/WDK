%returns the FFT
classdef FFT < Computer
    
    methods (Access = public)
        
        function obj = FFT()
            obj.name = 'FFT';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function Y = compute(~,x)
            N = length(x);
            Y = fft(x);
            Y = Y(1:floor(N/2)+1);
        end
        
        function metrics = computeMetrics(~,input)
            
            n = size(input,1);
            if Helper.IsPowerOf2(n)
                flops = n;
            else
                flops = n * n;
            end
            memory = n * 4;
            outputSize = n/2  * Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
