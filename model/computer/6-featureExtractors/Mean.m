classdef Mean < Computer
    
    methods (Access = public)
        
        function obj = Mean()
            obj.name = 'Mean';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = mean(signal);
        end
    end
end