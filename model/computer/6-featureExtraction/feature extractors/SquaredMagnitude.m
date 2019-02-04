classdef SquaredMagnitude < Computer
    
    methods (Access = public)
        
        function obj = SquaredMagnitude()
            obj.name = 'SquaredMagnitude';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(signal.^2);
        end
    end
end