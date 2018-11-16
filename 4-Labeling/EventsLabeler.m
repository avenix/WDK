classdef EventsLabeler < handle
    
    properties (Access = public)
        labelingStrategy;
        tolerance = 10;
    end
    
    methods (Access = public)
        
        function obj = EventsLabeler(labelingStrategy)
            obj.labelingStrategy = labelingStrategy;
        end
        
        function labels = label(obj,detectedEvents, eventAnnotations)
            if isempty(obj.labelingStrategy)
                classes = obj.labelWithEventAnnotations(detectedEvents,eventAnnotations);
                labels = obj.labelingStrategy.labelsForClasses(classes);
            end
        end
    end
    
    methods (Access = private)
        
        function  labels = labelWithEventAnnotations(obj,detectedEvents,eventAnnotations)
            detectedEvents = sort(detectedEvents);
            
            nSegments = length(detectedEvents);
            labels = zeros(1,nSegments);
            
            for currentSegment = 1 : nSegments
                
                detectedEventLocation = detectedEvents(currentSegment);
                annotationIdx = EventsLabeler.findIdxOfSampleNearEventAnnotations(detectedEventLocation,eventAnnotations,obj.tolerance);
                
                if annotationIdx > 0
                    eventAnnotation = eventAnnotations(annotationIdx);
                    labels(currentSegment) = eventAnnotation.label;
                else
                    labels(currentSegment) = obj.labelingStrategy.nullClass;
                end
            end
        end
    end
    
    methods (Static)
        function idx = findIdxOfSampleNearEventAnnotations(sample1,eventAnnotations,tolerance)
            idx = -1;
            for i = 1 : length(eventAnnotations)
                eventAnnotation = eventAnnotations(i);
                if abs(int32(eventAnnotation.sample) - int32(sample1)) < tolerance
                    idx = i;
                elseif eventAnnotation.sample > sample1
                    break;
                end
            end
        end
    end
end