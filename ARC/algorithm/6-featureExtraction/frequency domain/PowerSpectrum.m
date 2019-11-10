classdef PowerSpectrum < Algorithm
    
    methods (Access = public)
        
        function obj = PowerSpectrum()
            obj.name = 'PowerSpectrum';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            N = length(Y);
            result = (sqrt(abs(Y) .* abs(Y)) * 2 ) / N;
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n;
            memory = n * 4;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end
