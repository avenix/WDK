classdef Max < Computer
    
    methods (Access = public)
        
        function obj = Max()
            obj.name = 'Max';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = max(signal);
        end
    end
end