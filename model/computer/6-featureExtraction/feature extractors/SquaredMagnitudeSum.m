classdef SquaredMagnitudeSum < Computer
    
    methods (Access = public)
        
        function obj = SquaredMagnitudeSum()
            obj.name = 'SquaredMagnitudeSum';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(signal.^2);
        end
    end
end