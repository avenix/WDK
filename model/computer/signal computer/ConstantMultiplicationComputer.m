classdef ConstantMultiplicationComputer < Computer
    
    properties (Access = public)
        constant;
    end
    
    methods (Access = public)
        
        function obj = ConstantMultiplicationComputer(constant)
            if nargin > 0
                obj.constant = constant;
            end
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = signal .* obj.constant;
        end
        
        function str = toString(obj)
            str = sprintf('CMult%d',obj.constant);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('constant',obj.constant);
        end
    end
end
