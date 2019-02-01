classdef ForEachComputer < Computer
    
    methods (Access = public)
        function obj = ForEachComputer()
            obj.inputPort = ComputerPort(ComputerPortType.kAny);
            obj.outputPort = ComputerPort(ComputerPortType.kAny);
            obj.name = 'ForEachComputer';
        end
        
        function outputSignal = compute(obj,elements)
            
        end
    end
end