classdef AUC < Computer
    
    properties (Access = public)
        windowSize;
    end
    
    methods (Access = public)
        
        function obj = AUC()
            obj.name = 'AUC';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(obj,signal)
            localWindowSize = obj.windowSize;
            if isempty(obj.windowSize)
                localWindowSize = length(signal);
            end
            
            %integrates the signal
            result = 0;
            for startIndex = 1 : localWindowSize : length(signal)-1
                endIndex = startIndex + localWindowSize-1;
                endIndex = min(endIndex,length(signal));
                window = signal(startIndex:endIndex);
                result = result + trapz(window);
            end
        end
        
        function metrics = computeMetrics(~,input)        
            flops = 8 * size(input,1);
            memory = 1;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
