classdef PropertySetter < Computer
    
    properties (Access = public)
        node;
        property;
    end
    
    methods (Access = public)
        function obj = PropertySetter()
            obj.name = 'propertySetter';
            obj.inputPort = ComputerDataType.kAny;
            obj.outputPort = ComputerDataType.kNull;
        end
        
        function computedSignal = compute(obj,data)
            obj.node.(obj.property) = data;
            computedSignal = [];
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s_%s',obj.name,obj.node.toString(),obj.property);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('property',obj.property);
        end
        
        function metrics = computeMetrics(~,input)
            metrics = Metric(1,1,0);
        end
    end
end
