%each event detector approach should return an array of indices
classdef (Abstract) EventDetector < handle
    properties (Access = public)
        type;
    end
    
    methods (Abstract)
        eventLocations = detectEvents(obj,data);
        [] = resetVariables(obj);
        str = toString(obj);
    end
    methods
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
    end
end