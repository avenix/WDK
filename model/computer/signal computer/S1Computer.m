classdef S1Computer < Computer
    properties (Access = public)
        k = 30;
    end
    
    methods (Access = public)
        
        function obj = S1Computer(k)
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
                
                leftMaximum = max(signalX - leftHalf);
                rightMaximum = max(signalX - rightHalf);
                computedSignal(signalIdx) = (leftMaximum + rightMaximum) / 2;
            end
        end
        
        
        function str = toString(~)
            str = 'S1';
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('k',obj.k);
        end
    end
end