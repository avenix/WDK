classdef MaxCrossCorr < Computer
    
    methods (Access = public)
        
        function obj = MaxCrossCorr()
            obj.name = 'MaxCrossCorr';
            obj.inputPort = ComputerDataType.kSignal2;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = max(xcorr(signal(:,1),signal(:,2)));
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 161 * n;
            memory = n;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
