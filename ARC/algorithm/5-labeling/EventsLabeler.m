classdef EventsLabeler < Algorithm
    
    properties (Access = public)
        tolerance = 10;
        manualAnnotations;
    end
    
    methods (Access = public)
        
        function obj = EventsLabeler()
            obj.name = 'eventsLabeler';
            obj.inputPort = DataType.kEvent;
            obj.outputPort = DataType.kEvent;
        end
        
        function labeledEvents = compute(obj, events)
            if isempty(events)
                labeledEvents = [];
            elseif ~isa(events(1),'Data') || events(1).type ~= DataType.kEvent
                labeledEvents = [];
                expectedStr = DataType.DataTypeToString(DataType.kEvent);
                if isa(events(1),'Data')
                    Helper.PrintWrongDataTypeMessage(DataType.DataTypeToString(events(1).type),...
                        expectedStr,obj.toString());
                else
                    Helper.PrintWrongDataTypeMessage(class(events(1)),expectedStr,obj.toString());
                end
            else
                labels = obj.labelEventIdxs([events.sample],obj.manualAnnotations.eventAnnotations);
                labeledEvents = EventsLabeler.LabelEventsWithValidLabels(events,labels);
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
    
    methods (Access = private, Static)
        
        function labeledEvents = LabelEventsWithValidLabels(events,labels)
            isValidLabel = ~Labeling.ShouldIgnoreLabels(labels);
            
            nValidEvents = sum(isValidLabel);
            labeledEvents = repmat(Event,1,nValidEvents);
            eventCounter = 1;
            for i = 1 : length(events)
                if isValidLabel(i)
                    event = events(i);
                    event.label = labels(i);
                    labeledEvents(eventCounter) = event;
                    eventCounter = eventCounter + 1;
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
