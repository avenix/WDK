classdef MAD < Computer
    
    methods (Access = public)
        
        function obj = MAD()
            obj.name = 'MAD';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = mad(signal);
        end
    end
    
end