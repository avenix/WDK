classdef SignalVectorMagnitude < Computer
    
    methods (Access = public)
        
        function obj = SignalVectorMagnitude()
            obj.name = 'SignalVectorMagnitude';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = sum(signal) / length(signal);
        end
    end
end
