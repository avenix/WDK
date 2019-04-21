classdef Subtractor < Computer
    
    methods (Access = public)
        
        function obj = Subtractor()
            obj.name = 'subtractor';
            obj.inputPort = ComputerDataType.kSignal2;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function computedSignal = compute(~,dataIn)
            computedSignal = dataIn(:,1) - dataIn(:,2);
        end
    end
end
