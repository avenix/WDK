
classdef SpectralCentroid < Algorithm
    
    methods (Access = public)
        
        function obj = SpectralCentroid()
            obj.name = 'SpectralCentroid';
            obj.inputPort = AlgorithmDataType.kSignal;
            obj.outputPort = AlgorithmDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)

            N = length(Y);
            windowFFT = abs(Y)/ N;
            windowFFT = windowFFT / max(windowFFT);
            
            m = ((1/(2*N))*(1:N))';
            result = sum(m.*windowFFT) / (sum(windowFFT)+eps);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 10 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
        
    end
end

