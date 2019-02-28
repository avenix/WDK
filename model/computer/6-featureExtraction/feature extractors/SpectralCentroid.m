
classdef SpectralCentroid < Computer
    
    methods (Access = public)
        
        function obj = SpectralCentroid()
            obj.name = 'SpectralCentroid';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        %receives a fourier transform
        function result = compute(~,Y)

            N = length(Y);
            windowFFT = abs(Y)/ N;
            windowFFT = windowFFT(1:ceil(N/2));
            
            fs = 100;
            
            windowLength = length(windowFFT);
            m = ((fs/(2*windowLength))*(1:windowLength))';
            windowFFT = windowFFT / max(windowFFT);
            
            result = sum(m.*windowFFT)/ (sum(windowFFT)+eps);
            
            % normalize by fs/2 (so that 1 correponds to the maximum signal frequency, i.e. fs/2):
            result = result / (fs/2);
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n * log(n) + 10 * n;
            memory = n * 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
        
    end
end

