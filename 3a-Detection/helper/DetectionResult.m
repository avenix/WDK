%contains arrays of ManualEvents: goodEvents, missedEvents, badEvents
classdef DetectionResult < handle
    properties
        goodEvents;
        missedEvents;
        badEvents;
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
        
        function str = toString(obj)
            
            numTotalEvents = obj.numGoodEvents() + obj.numMissedEvents();
            goodEventRate = 100 * obj.numGoodEvents() / numTotalEvents;
            badEventRate =  obj.numBadEvents() / numTotalEvents;
            str = sprintf('%7.1f%%|x%.2f(%d)',goodEventRate,badEventRate,obj.numBadEvents());
        end
    end
    
    methods (Static, Access = private)
        function goodEventsPerClass = numEventsPerClass(events,nClasses)
            goodEventsPerClass = zeros(1,nClasses);
            for i = 1 : length(events)
                event = events(i);
                label = event.label;
                goodEventsPerClass(label) = goodEventsPerClass(label) + 1;
            end
        end
    end
end