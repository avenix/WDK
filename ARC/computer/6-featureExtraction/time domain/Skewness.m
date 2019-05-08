classdef Skewness < Computer
    
    methods (Access = public)
        
        function obj = Skewness()
            obj.name = 'Skewness';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            %meanComputer = dsp.Mean('RunningMean',false,'Dimension','All');
            %signalMean = step(meanComputer,signal);
            signalMean = mean(signal);
            
            n = single(length(signal));
            
            upper = single(0);
            lower = single(0);
            for i = 1 : n
                temp = single(signal(i) - signalMean);
                temp2 = single(temp * temp);
                upper = upper + temp2 * temp;
                lower = lower + temp2;
            end
            lower = lower / n;
            result = upper / (n * lower^1.5);
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 6 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end
