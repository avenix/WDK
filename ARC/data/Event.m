classdef Event < Data
    properties (Access = public)
        sample;
        label;
    end
    
    methods (Access = public)
        function obj = Event(sample,label)
            if nargin == 2
                obj.sample = sample;
                obj.label = label;
            end
            obj.type = DataType.kEvent;
        end
    end
    
    methods (Access = public, Static)
        
        %creates an array of events with the provided locations and an
        %empty label
        function events = EventsArrayWithEventLocations(eventLocations)
            nEvents = length(eventLocations);
            events = repmat(Event,1,nEvents);
            
            for i = 1 : nEvents
                eventLocation = eventLocations(i);
                events(i) = Event(eventLocation,[]);
            end
        end
    end
end