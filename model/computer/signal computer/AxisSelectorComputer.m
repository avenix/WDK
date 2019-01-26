classdef AxisSelectorComputer < Computer
    
    properties (Access = public)
        axes;
    end
    
    methods (Access = public)
        
        function obj = AxisSelectorComputer(axes)
            if nargin > 0
                obj.axes = axes;
            end
        end
        
        function computedSignal = compute(obj,signal)
            nCols = size(signal,2);
            maxExpectedAxes = max(obj.axes);
            if nCols <= maxExpectedAxes
                fprintf('AxisSelectorComputer - %s. input size has: %d columns but should have up to %d columns',Constants.kInvalidInputError,nCols,maxExpectedAxes);
            end
            computedSignal = signal(:,obj.axes);
        end
        
        function str = toString(obj)
            axesStr = Helper.arrayToString(obj.axes);
            axesStr = strrep(axesStr,'\n','');
            str = sprintf('AxisSel%s',axesStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('axes',array2JSON(obj.axes));
        end
    end
end