classdef Zrc < Computer
    
    methods (Access = public)
        
        function obj = Zrc()
            obj.name = 'Zrc';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = zrc(signal);
        end
    end
end