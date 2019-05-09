classdef AAV < Computer
    
    methods (Access = public)
        
        function obj = AAV()
            obj.name = 'AAV';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            result = single(0);
            
            for i = 1 : length(signal)-1
                result = result + single(abs(signal(i+1) - signal(i)));
            end
            result = result / length(signal);
        end
        
        function metrics = computeMetrics(~,input)
            flops = 5 * size(input,1);
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
