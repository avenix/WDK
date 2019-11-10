classdef S2 < Algorithm
    properties (Access = public)
        k = 30;
    end
    
    methods (Access = public)
        
        function obj = S2(k)
            if nargin > 0
                obj.k = k;
            end
            obj.name = 'S2';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kSignal;
        end
        
        function computedSignal = compute(obj,signal)
            nSamples = length(signal);
            computedSignal = single(zeros(1,nSamples));
            
            for signalIdx = obj.k + 1 : nSamples - obj.k
                signalX = signal(signalIdx);
                leftHalf = signal(signalIdx - obj.k : signalIdx - 1);
                rightHalf = signal(signalIdx + 1 : signalIdx + obj.k);
                
                leftMean = mean(signalX - leftHalf);
                rightMean = mean(signalX - rightHalf);
                computedSignal(signalIdx) = (leftMean + rightMean) / 2;
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d',obj.name,obj.k);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('k',obj.k,1,50);
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            flops = 203 * obj.k * n;
            memory = n * Constants.kSensorDataBytes;
            outputSize = n * Constants.kSensorDataBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
