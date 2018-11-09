classdef AxisSelectorComputer < Computer
    
    properties (Access = public)
        axis;
    end
    
    methods (Access = public)
        
        function obj = AxisSelectorComputer()
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = signal(obj.axis);
        end
        
        function str = toString(~)
            str = 'AxisSelectorComputer';
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = [Property('axis',array2JSON(obj.axis))];
        end
    end
end