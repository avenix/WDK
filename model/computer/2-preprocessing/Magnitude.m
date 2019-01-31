classdef Magnitude < Computer
    
    methods (Access = public)
        
        function obj = Magnitude()
            obj.name = 'Magnitude';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal, ComputerSizeType.kNx3);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
        end
        
        function dataOut = compute(~,x)
            dataOut = sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2);
        end
    end
end