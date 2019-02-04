classdef Min < Computer
    
    methods (Access = public)
        
        function obj = Min()
            obj.name = 'Min';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = min(signal);
        end
    end
end