classdef Variance < Computer
    
    methods (Access = public)
        
        function obj = Variance()
            obj.name = 'Variance';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = var(signal);
        end
    end
end