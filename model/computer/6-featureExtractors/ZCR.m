classdef ZCR < Computer
    
    methods (Access = public)
        
        function obj = ZCR()
            obj.name = 'ZCR';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            N = length(signal);
            result = sum(abs(diff(data>0))) / N;
        end
    end
end