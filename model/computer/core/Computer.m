classdef (Abstract) Computer < handle
    
    properties (Access = public)
        inputPort;
        outputPort;
        name;
    end
    
    methods (Abstract)
        computedSignal = compute(obj,signal);
    end
    
    methods (Access = public)
        %do not comment out the obj parameter
        function setProperty(obj, property)
            setExpression = sprintf('obj.%s=%d;',property.name,property.value);
            eval(setExpression);
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = [];
        end
    end
end