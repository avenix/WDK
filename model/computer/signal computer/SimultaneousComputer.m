classdef SimultaneousComputer < CompositeComputer
    properties (Access = public)
        type =  'simult';
    end
    
    methods (Access = public)

        function outputSignal = compute(obj,signal)
            n = size(signal,1);
            m = length(obj.computers);
            outputSignal = zeros(n,m);
            for i = 1 : m
                outputSignal(:,i) = obj.computers{i}.compute(signal);
            end
        end
    end
end