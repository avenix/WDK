classdef Kurtosis < Computer
    
    methods (Access = public)
        
        function obj = Kurtosis()
            obj.name = 'Kurtosis';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        function result = compute(~,signal)
            
            %meanComputer = dsp.Mean('RunningMean',false,'Dimension','All');
            %signalMean = step(meanComputer,signal);
            signalMean = mean(signal);
            
            upper = single(0);
            lower = single(0);
            
            n = single(length(signal));
            
            for i = 1 : n
                temp = single(signal(i) - signalMean);
                temp2 = single(temp * temp);
                upper = upper + temp2 * temp2;
                lower = lower + temp2;
            end
            lower = lower / n;
            result = upper / (n*lower*lower);
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
