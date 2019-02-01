classdef SequentialComputer < CompositeComputer
    
    methods (Access = public)
        function obj = SequentialComputer(computers)
            obj = obj@CompositeComputer(computers);
        end
        
        function signal = compute(obj,signal)
            for i = 1 : length(obj.computers)
                signal = obj.computers{i}.compute(signal);
            end
        end
    end
end