%returns the first component of the frequency representation of the signal
classdef SpectralSpread < Computer
    
    methods (Access = public)
        
        function obj = SpectralSpread()
            obj.name = 'SpectralSpread';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            
            fs = 100;
            
            N = length(Y);
            windowFFT = abs(Y) / N;
            windowFFT = windowFFT(1:ceil(N/2));
            
            windowLength = length(windowFFT);
            m = ((fs/(2*windowLength))*(1:windowLength))';
            windowFFT = windowFFT / max(windowFFT);
            
            % compute the spectral spread
            C = sum(m.*windowFFT)/ (sum(windowFFT)+eps);
            result = sqrt(sum(((m-C).^2).*windowFFT)/ (sum(windowFFT)+eps));
            
            result = result / (fs/2);
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
