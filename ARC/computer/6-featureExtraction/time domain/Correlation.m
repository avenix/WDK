classdef Correlation < Computer
    
    methods (Access = public)
        
        function obj = Correlation()
            obj.name = 'Correlation';
            obj.inputPort = ComputerDataType.kSignal2;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %input signal is nx2
        function result = compute(~,signal)
            result = corrcoef(signal);
            result = result(1,2);
        end
        
        %TODO: recalculate these metrics
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 3 * n;
            memory = n;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
