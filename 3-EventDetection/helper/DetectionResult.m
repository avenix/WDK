%contains arrays of ManualEvents: goodEvents, missedEvents, badEvents
classdef DetectionResult < handle
    properties
        goodEvents;%array of Event
        missedEvents;%array of EventAnnotation
        badEvents;%array of Event
    end
    
    properties (Dependent)
        numGoodEvents;
        numMissedEvents;
        numBadEvents;
        FPEventRate;
        recall;
        precision;
        f1Score;
    end
    
    methods 
                
        function nGoodEvents = get.numGoodEvents(obj)
            nGoodEvents = length(obj.goodEvents);
        end
        
        function nMissedEvents = get.numMissedEvents(obj)
            nMissedEvents = length(obj.missedEvents);
        end
        
        function nBadEvents = get.numBadEvents(obj)
            nBadEvents = length(obj.badEvents);
        end
        
        function er = get.recall(obj)
            er = obj.numGoodEvents / (obj.numGoodEvents + obj.numMissedEvents);
        end
        
        function er = get.FPEventRate(obj)
            er =  obj.numBadEvents / (obj.numGoodEvents + obj.numMissedEvents);
        end
        
        function precision = get.precision(obj)
            precision =  obj.numGoodEvents / (obj.numGoodEvents + obj.numBadEvents);
        end
        
        function f1Score = get.f1Score(obj)
            p = obj.precision;
            r = obj.recall;
            f1Score = (2 * r * p) / (r + p);
        end
        
    end
    
    methods (Access = public)
        function obj = DetectionResult(goodEvents,missedEvents,badEvents)
            if nargin > 0
                obj.goodEvents = goodEvents;
                obj.missedEvents = missedEvents;
                obj.badEvents = badEvents;
            end
        end
        
        function goodEventsPerClass = numGoodEventsPerClass(obj,nClasses)
            goodEventsPerClass = DetectionResult.NumEventsPerClass(obj.goodEvents,nClasses);
        end
        
        function missedEventsPerClass = numMissedEventsPerClass(obj,nClasses)
            missedEventsPerClass = DetectionResult.NumEventsPerClass(obj.missedEvents,nClasses);
        end
    end
    
    methods (Static, Access = private)
        function eventsPerClass = NumEventsPerClass(events,nClasses)
            countMap = containers.Map('KeyType','double','ValueType','double');
            
            for i = 1 : length(events)
                event = events(i);
                label = event.label;
                if isKey(countMap,label)
                    countMap(label) = countMap(label) + 1;
                else
                    countMap(label) = 1;
                end
            end
            eventsPerClass = DetectionResult.CreateEventsPerClassArray(countMap,nClasses);
        end
        
        function eventsPerClass = CreateEventsPerClassArray(countMap,nClasses)
            eventsPerClass = zeros(1,nClasses);
            for i = 1 : nClasses
                if isKey(countMap,i)
                    eventsPerClass(i) = countMap(i);
                end
            end
        end
    end
end