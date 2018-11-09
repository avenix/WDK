classdef S2Computer < Computer
    properties (Access = public)
        k = 30;
    end
    
    methods (Access = public)
        
        function obj = S2Computer(k)
            if nargin > 0
                obj.k = k;
            end
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
        
        
        function str = toString(~)
            str = 'S2';
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('k',obj.k);
        end
    end
end