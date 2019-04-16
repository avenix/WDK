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
            flops = 4 * n + 1;
            memory = 4;
            outputSize = 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
