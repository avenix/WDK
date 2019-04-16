classdef Correlation < Computer
    
    methods (Access = public)
        
        function obj = Correlation()
            obj.name = 'Correlation';
            obj.inputPort = ComputerDataType.kSignal2;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function result = compute(~,signal)
            result = corrcoef(signal);
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 18 * n;
            memory = 4;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
