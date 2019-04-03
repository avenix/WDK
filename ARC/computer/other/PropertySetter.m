classdef PropertySetter < Computer
    
    properties (Access = public)
        node;
        property;
    end
    
    methods (Access = public)
        function obj = PropertySetter()
            obj.name = 'propertySetter';
            obj.inputPort = ComputerPort(ComputerPortType.kAny);
            obj.outputPort = ComputerPort(ComputerPortType.kNull);
        end
        
        function computedSignal = compute(obj,data)
            setExpression = sprintf('obj.node.%s=%d;',obj.property,data);
            computedSignal = eval(setExpression);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s_%s',obj.name,obj.node.toString(),obj.property);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('property',obj.property);
        end
    end
end