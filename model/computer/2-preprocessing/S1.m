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
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
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
    end
end