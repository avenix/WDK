classdef MaxCrossCorr < Computer
    
    methods (Access = public)
        
        function obj = MaxCrossCorr()
            obj.name = 'MaxCrossCorr';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kNx2);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(~,signal)
            result = max(xcorr(signal(:,1),signal2(:,2)));
        end
    end
end