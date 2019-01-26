classdef SequentialComputer < CompositeComputer
    properties (Access = public)
        type =  'seq';
    end
    
    methods (Access = public)
        function signal = compute(obj,signal)
            for i = 1 : length(obj.computers)
                signal = obj.computers{i}.compute(signal);
            end
        end
    end
end