classdef EventsLabeler < handle
    
    properties (Access = public)
        labelingStrategy;
        tolerance = 10;
        classesMap;
    end
    
    methods (Access = public)
        
        function obj = EventsLabeler(labelingStrategy)
            obj.labelingStrategy = labelingStrategy;
            obj.classesMap = ClassesMap.instance();
        end
        
        function labels = label(obj,detectedEvents, eventAnnotations)
            if ~isempty(obj.labelingStrategy)
                classes = obj.labelWithEventAnnotations(detectedEvents,eventAnnotations);
                labels = obj.labelingStrategy.labelsForClasses(classes);
            end
        end
        
        function invalidIdxs = getInvalidLabels(obj,labels)
            invalidIdxs = (labels == ClassesMap.kInvalidClass | labels == obj.classesMap.synchronisationClass);
        end
        
    end
    
    methods (Access = private)
        
        function  labels = labelWithEventAnnotations(obj,detectedEvents,eventAnnotations)
            detectedEvents = sort(detectedEvents);
            
            nEvents = length(detectedEvents);
            labels = zeros(1,nEvents);
            
            for i = 1 : nEvents
                
                detectedEventLocation = detectedEvents(i);
                annotationIdx = EventsLabeler.findIdxOfSampleNearEventAnnotations(detectedEventLocation,eventAnnotations,obj.tolerance);
                
                if annotationIdx > 0
                    eventAnnotation = eventAnnotations(annotationIdx);
                    labels(i) = eventAnnotation.label;
                else
                    labels(i) = obj.labelingStrategy.nullClass;
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