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
        
        function str = toString(obj)
            axesStr = Helper.arrayToString(obj.axes);
            axesStr = strrep(axesStr,'\n','');
            str = sprintf('AxisSel%s',axesStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = [Property('axes',array2JSON(obj.axes))];
        end
    end
end