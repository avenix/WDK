classdef EventsLabeler < Computer
    
    properties (Access = public)
        tolerance = 10;
        manualAnnotations;
    end
    
    methods (Access = public)
        
        function obj = EventsLabeler()
            obj.name = 'eventsLabeler';
            obj.inputPort = ComputerDataType.kEvent;
            obj.outputPort = ComputerDataType.kEvent;
        end
        
        function labeledEvents = compute(obj, events)
            if isempty(events)
                labeledEvents = [];
            else
                labels = obj.labelEventIdxs([events.sample],obj.manualAnnotations.eventAnnotations);
                labeledEvents = Helper.LabelEventsWithValidLabels(events,labels);
            end
        end
        
        function labels = labelEventIdxs(obj, eventLocations, eventAnnotations)
            eventLocations = sort(eventLocations);
            
            nEvents = length(eventLocations);
            labels = zeros(1,nEvents);
            for i = 1 : nEvents
                
                eventLocation = eventLocations(i);
                annotationIdx = EventsLabeler.findIdxOfSampleNearEventAnnotations(eventLocation,eventAnnotations,obj.tolerance);
                
                if annotationIdx > 0
                    eventAnnotation = eventAnnotations(annotationIdx);
                    labels(i) = eventAnnotation.label;
                else
                    labels(i) = Labeling.kNullClass;
                end
            end
        end
    end

    methods (Static)
        
        
        function idx = findIdxOfSampleNearEventAnnotations(sample,eventAnnotations,tolerance)
            idx = -1;
            for i = 1 : length(eventAnnotations)
                eventAnnotation = eventAnnotations(i);
                if abs(int32(eventAnnotation.sample) - int32(sample)) < tolerance
                    idx = i;
                elseif eventAnnotation.sample > sample
                    break;
                end
            end
        end
    end
end
