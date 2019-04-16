classdef AxisMerger < Computer
    
    properties (Access = public)
        nAxes;
    end
    
    properties (Access = private)
        currentAxis = 0;
        mergedSignal;
    end
    
    methods (Access = public)
        
        function obj = AxisMerger(nAxes)
            if nargin > 0
                obj.nAxes = nAxes;
            end
            obj.name = 'AxisMerger';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignalN;
        end
        
        function outputSignal = compute(obj,signal)
            
            obj.currentAxis = obj.currentAxis + 1;
            obj.mergedSignal(:,obj.currentAxis) = signal;
            
            if(obj.currentAxis == obj.nAxes)
                outputSignal = obj.mergedSignal;
                obj.mergedSignal = [];
                obj.currentAxis = 0;
            else
                outputSignal = [];
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s%s',obj.name,obj.nAxes);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('nAxes',obj.nAxes);
            editableProperties.type = PropertyType.kNumber;
        end
    end
end
