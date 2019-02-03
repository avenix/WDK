classdef STD < Computer
    
    methods (Access = public)
        
        function obj = STD()
            obj.name = 'STD';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = std(signal);
        end
    end
end