classdef SMA < Computer
    
    methods (Access = public)
        
        function obj = SMA()
            obj.name = 'SMA';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kNxN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(sum(abs(signal)));
        end
    end
end