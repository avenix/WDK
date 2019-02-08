classdef Subtraction < Computer
    
    methods (Access = public)
        
        function obj = Subtraction()
            obj.name = 'subtraction';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
        end
        
        function computedSignal = compute(~,signal)
            computedSignal = signal(:,1) - signal(:,2);
        end
    end
end