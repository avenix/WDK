%each event detector approach should return an array of indices
classdef (Abstract) EventDetector < handle
    properties (Access = public)
        name;
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
    
    methods (Static)
        function events = CreateEventsWithEventLocations(eventLocations)
            nEvents = length(eventLocations);
            events = repmat(EventAnnotation,1,nEvents);
            
            for i = 1 : nEvents
                eventLocation = eventLocations(i);
                events(i) = EventAnnotation(eventLocation,[]);
            end
        end
    end
end