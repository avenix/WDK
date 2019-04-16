classdef Subtraction < Computer
    
    methods (Access = public)
        
        function obj = Subtraction()
            obj.name = 'subtraction';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function computedSignal = compute(~,dataIn)
            computedSignal = dataIn{1} - dataIn{2};
        end
    end
end
