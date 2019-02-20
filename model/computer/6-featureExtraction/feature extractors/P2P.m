classdef P2P < Computer
    
    methods (Access = public)
        
        function obj = P2P()
            obj.name = 'P2P';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = peak2peak(signal);
        end
    end
end