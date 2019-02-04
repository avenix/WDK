classdef Entropy < Computer
    
    methods (Access = public)
        
        function obj = Entropy()
            obj.name = 'Entropy';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
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
    end
    
end