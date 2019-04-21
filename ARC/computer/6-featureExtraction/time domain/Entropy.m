classdef Entropy < Computer
    
    methods (Access = public)
        
        function obj = Entropy()
            obj.name = 'Entropy';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            
            alphabet = unique(signal);
            freq = zeros(size(alphabet));
            
            for symbol = 1:length(alphabet)
                freq(symbol) = sum(signal == alphabet(symbol));
            end
            
            P = freq / sum(freq);
            result = -sum(P .* log2(P));
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = n * n;
            memory = n;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end
