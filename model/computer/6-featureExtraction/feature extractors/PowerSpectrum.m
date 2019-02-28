classdef PowerSpectrum < Computer
    
    methods (Access = public)
        
        function obj = PowerSpectrum()
            obj.name = 'PowerSpectrum';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            
            N = length(Y);
            
            result = ((sqrt(abs(Y).*abs(Y)) * 2 )/N);
            result = result(1:floor(N/2));
        end
        
             
        %TODO: recalculate these metrics   
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 4 * n * log2(n) + 2 * n;
            memory = n * 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end