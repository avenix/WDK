classdef Subtraction < Computer
    
    methods (Access = public)
        
        function obj = Subtraction()
            obj.name = 'subtraction';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
        end
        
        function computedSignal = compute(~,dataIn)
            computedSignal = dataIn{1} - dataIn{2};
        end
    end
end