%contains arrays of ManualEvents: goodEvents, missedEvents, badEvents
classdef DetectionResult < handle
    properties
        goodEvents;
        missedEvents;
        badEvents;
    end
    
    properties (Dependent)
        goodEventRate;
        badEventRate;
    end
    
    methods 
        function er = get.goodEventRate(obj)
            numTotalEvents = obj.numGoodEvents() + obj.numMissedEvents();
            er = obj.numGoodEvents() / numTotalEvents;
        end
        
        function er = get.badEventRate(obj)
            numTotalEvents = obj.numGoodEvents() + obj.numMissedEvents();
            er =  obj.numBadEvents() / numTotalEvents;
        end
    end
    
    methods (Access = public)
        function obj = DetectionResult(goodEvents,missedEvents,badEvents)
            if nargin>1
                obj.goodEvents = goodEvents;
                obj.missedEvents = missedEvents;
                obj.badEvents = badEvents;
            end
        end
        
        function nGoodEvents = numGoodEvents(obj)
            nGoodEvents = length(obj.goodEvents);
        end
        
        function nMissedEvents = numMissedEvents(obj)
            nMissedEvents = length(obj.missedEvents);
        end
        
        function nBadEvents = numBadEvents(obj)
            nBadEvents = length(obj.badEvents);
        end
        
        function goodEventsPerClass = numGoodEventsPerClass(obj,nClasses)
            goodEventsPerClass = DetectionResult.numEventsPerClass(obj.goodEvents,nClasses);
        end
        
        function missedEventsPerClass = numMissedEventsPerClass(obj,nClasses)
            missedEventsPerClass = DetectionResult.numEventsPerClass(obj.missedEvents,nClasses);
        end
    end
    
    methods (Static, Access = private)
        function numEventsPerClass = numEventsPerClass(events,nClasses)
            numEventsPerClass = zeros(1,nClasses);
            for i = 1 : length(events)
                event = events(i);
                label = event.label;
                numEventsPerClass(label) = numEventsPerClass(label) + 1;
            end
        end
    end
end