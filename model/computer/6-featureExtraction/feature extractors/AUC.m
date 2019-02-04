classdef AUC < Computer
    
    properties (Access = public)
        windowSize;
    end
    
    methods (Access = public)
        
        function obj = AUC()
            obj.name = 'AUC';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function result = compute(obj,signal)
            localWindowSize = obj.windowSize;
            if isempty(obj.windowSize)
                localWindowSize = length(signal);
            end
            
            %integrates the signal
            result = 0;
            for i = 0 : localWindowSize : length(signal)-1
                startIndex = i * localWindowSize + 1;
                endIndex = startIndex + localWindowSize;
                endIndex = min(endIndex,length(signal));
                window = signal(startIndex:endIndex);
                result = result + trapz(window);
            end
        end
    end
end