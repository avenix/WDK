classdef Energy < Computer
    
    methods (Access = public)
        
        function obj = Energy()
            obj.name = 'Energy';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = sum(signal.^2);
        end
                
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 2 * n;
            memory = 1;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
