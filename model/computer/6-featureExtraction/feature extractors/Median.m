classdef Median < Computer
    
    methods (Access = public)
        
        function obj = Median()
            obj.name = 'Median';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = median(signal);
        end
    end
end