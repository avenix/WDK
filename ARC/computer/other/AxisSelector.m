classdef AxisSelector < Computer
    
    properties (Access = public)
        axes;
    end
    
    methods (Access = public)
        
        function obj = AxisSelector(axes)
            if nargin > 0
                obj.axes = axes;
            end
            obj.name = 'AxisSelector';
            obj.inputPort = ComputerPort(ComputerPortType.kSignalN);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal);
        end
        
        function computedSignal = compute(obj,signal)
            nCols = size(signal,2);
            maxExpectedAxes = max(obj.axes);
            if nCols < maxExpectedAxes
                fprintf('AxisSelector - %s. input size has: %d columns but should have up to %d columns',Constants.kInvalidInputError,nCols,maxExpectedAxes);
            end
            computedSignal = signal(:,obj.axes);
        end
        
        function str = toString(obj)
            axesStr = Helper.arrayToString(obj.axes,'');
            str = sprintf('%s%s',obj.name,axesStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            axesStr = sprintf('[%s]',Helper.arrayToString(obj.axes,','));
            editableProperties = Property('axes',axesStr);
            editableProperties.type = PropertyType.kArray;
        end
    end
end