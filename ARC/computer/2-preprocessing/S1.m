classdef S1 < Computer
    properties (Access = public)
        k = 30;
    end
    
    methods (Access = public)
        
        function obj = S1(k)
            if nargin > 0
                obj.k = k;
            end
            obj.name = 'S1';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function computedSignal = compute(obj,signal)
            nSamples = length(signal);
            computedSignal = single(zeros(1,nSamples));
            
            for signalIdx = obj.k + 1 : nSamples - obj.k
                signalX = signal(signalIdx);
                leftHalf = signal(signalIdx - obj.k : signalIdx - 1);
                rightHalf = signal(signalIdx + 1 : signalIdx + obj.k);
                
                leftMaximum = max(signalX - leftHalf);
                rightMaximum = max(signalX - rightHalf);
                computedSignal(signalIdx) = (leftMaximum + rightMaximum) / 2;
            end
        end
        
        
        function str = toString(obj)
            str = sprintf('%s_%d',obj.name,obj.k);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('k',obj.k,1,50);
        end
        
        function metrics = computeMetrics(obj,input)
            flops = (size(input,1) - 2 * obj.k) * (4 * obj.k +  3);
            memory = (size(input,1) + 2 * obj.k + 2) * 4;
            outputSize = size(input,1) * 4;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
