classdef AxisSelectorComputer < Computer
    
    properties (Access = public)
        axes;
    end
    
    methods (Access = public)
        
        function obj = AxisSelectorComputer()
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = signal(:,obj.axes);
        end
        
        function str = toString(~)
            str = 'AxisSelectorComputer';
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = [Property('axes',array2JSON(obj.axes))];
        end
    end
end