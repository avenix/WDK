classdef ConstantMultiplier < Computer
    
    properties (Access = public)
        constant;
    end
    
    methods (Access = public)
        
        function obj = ConstantMultiplier(constant)
            if nargin > 0
                obj.constant = constant;
            end
            obj.name = 'ConstantMultiplier';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = signal .* obj.constant;
        end
        
        function str = toString(obj)
            str = sprintf('%s%d',obj.name,obj.constant);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('constant',obj.constant);
        end
    end
end
