classdef (Abstract) Computer < handle
    
    properties (Access = public)
        expectedNumInputSignals;
    end
    
    methods (Abstract)
        computedSignal = compute(obj,signal);
        str = toString(obj);
        editableProperties = getEditableProperties(obj);
    end
    
    methods (Access = public)
        %do not comment out the obj parameter
        function setProperty(obj, property)
            setExpression = sprintf('obj.%s=%d;',property.name,property.value);
            eval(setExpression);
        end
    end
end