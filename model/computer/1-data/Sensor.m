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
            if isempty(obj.axes)
                computedSignal = dataFile.data;
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