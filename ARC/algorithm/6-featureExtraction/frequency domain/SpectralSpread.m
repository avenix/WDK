%returns the first component of the frequency representation of the signal
classdef SpectralSpread < Computer
    
    methods (Access = public)
        
        function obj = SpectralSpread()
            obj.name = 'SpectralSpread';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            N = length(Y);
            Y = abs(Y) / N;
            Y = Y / max(Y);
            
            m = ((1/(2*N))*(1:N))';
            
            % compute the spectral spread
            C = sum(m .* Y) / (sum(Y)+eps);
            result = sqrt(sum(((m-C).^2) .* Y)/ (sum(Y)+eps));
        end
                
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 11 * n;
            memory = n;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
