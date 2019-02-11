classdef IQR < Computer
    
    methods (Access = public)
        
        function obj = IQR()
            obj.name = 'IQR';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = iqr(signal);
        end
    end
end