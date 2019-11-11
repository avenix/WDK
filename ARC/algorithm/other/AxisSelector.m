classdef AxisSelector < Algorithm
    
    properties (Access = public)
        axes;
    end
    
    methods (Access = public)
        
        function obj = AxisSelector(axes)
            if nargin > 0
                obj.axes = axes;
            end
            obj.name = 'AxisSelector';
            obj.inputPort = DataType.kSignalN;
            obj.outputPort = DataType.kSignalN;
        end
        
        function computedSignal = compute(obj,signal)
            nCols = size(signal,2);
            maxExpectedAxes = max(obj.axes);
            if nCols < maxExpectedAxes
                fprintf('AxisSelector - %s. input size has: %d columns but should have up to %d columns\n',Constants.kInvalidInputError,nCols,maxExpectedAxes);
            end
            computedSignal = signal(:,obj.axes);
        end
        
        function str = toString(obj)
            axesStr = Helper.ArrayToString(obj.axes,'');
            str = sprintf('%s%s',obj.name,axesStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            axesStr = sprintf('[%s]',Helper.ArrayToString(obj.axes,','));
            editableProperties = Property('axes',axesStr);
            editableProperties.type = PropertyType.kArray;
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            m = size(input,2);
            flops = 1;
            memory = 1;
            outputSize = n * m;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
