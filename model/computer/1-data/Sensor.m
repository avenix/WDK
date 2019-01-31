classdef Sensor < Computer
    
    properties (Access = public)
        axes;
    end
    
    methods (Access = public)
        function obj = Sensor(axes)
            if (nargin > 0)
                obj.axes = axes;
            end
        end
        
        function computedSignal = compute(obj,dataFile)
            nCols = size(dataFile.data,2);
            maxExpectedAxes = max(obj.axes);
            if nCols > maxExpectedAxes
                fprintf('Sensor - %s. input size has: %d columns but should have up to %d columns',Constants.kInvalidInputError,nCols,maxExpectedAxes);
            else
                computedSignal = dataFile.data(:,obj.axes);
            end
        end
        
        function str = toString(obj)
            axesStr = Helper.arrayToString(obj.axes);
            axesStr = strrep(axesStr,'\n','');
            str = sprintf('%s%s',obj.name,axesStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('axes',array2JSON(obj.axes));
        end
    end
    
    methods (Access = private)
        function obj = maxValue(axes)
            if nargin > 0
                obj.axes = axes;
            end
            obj.name = 'sensor';
            obj.inputPort = ComputerPort(ComputerPortType.kDataFile);
            obj.outputPort = ComputerPort(ComputerPortType.kDataFile,kNxN);
        end
        
    end
end