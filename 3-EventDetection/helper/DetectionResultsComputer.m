%computes an array of DetectionResults (which contain arrays of labeled events: goodEvents, missedEvents, badEvents) per
%file
classdef DetectionResultsComputer < handle
    properties (Access = public)
        tolerance = 10;
        positiveLabels = [];
    end

    methods (Access = public)
        
        function obj = DetectionResultsComputer(positiveLabels)
            if nargin > 0
                obj.positiveLabels = positiveLabels;
            end
        end
        
        %returns an array of DetectionResults (one for each cell)
        function detectionResults = computeDetectionResults(obj,eventsCellArray,annotationsArray)
            
            nCells = length(eventsCellArray);
            detectionResults(1,nCells) = DetectionResult();
            for i = 1 : nCells
                annotationSet = annotationsArray(i);
                detectedEvents = eventsCellArray{i};
                detectionResults(i) = obj.computeDetectionResult(detectedEvents,annotationSet.eventAnnotations);
            end
        end
    end
    
    methods (Access = private)
        
         function r = isRelevantEvents(obj,detectedEvents)
            if isempty(detectedEvents)
                r = [];
            else
                labels = [detectedEvents.label];
                nLabels = length(labels);
                r = false(1,nLabels);
                for i = 1 : nLabels
                    r(i) = obj.isRelevantLabel(labels(i));
                end
            end
         end
         
         function b = isRelevantLabel(obj,label)
             if label == ClassesMap.kNullClass
                 b = false;
             elseif isempty(obj.positiveLabels)
                 b = true;
             else
                 b = obj.positiveLabels(label);
             end
         end
         
         function detectionResult = computeDetectionResult(obj,detectedEvents,eventAnnotations)

            isGoodEvent = obj.isRelevantEvents(detectedEvents);
            goodEvents = obj.computeGoodEvents(detectedEvents,isGoodEvent);
            badEvents = obj.computeBadEvents(detectedEvents,isGoodEvent);
            
            eventAnnotations = obj.removeIgnoredAnnotations(eventAnnotations);
            
            missedEvents = obj.computeMissedEventAnnotations(detectedEvents,eventAnnotations);
            detectionResult = DetectionResult(goodEvents,missedEvents,badEvents);
        end
        
        function eventAnnotations = removeIgnoredAnnotations(~, eventAnnotations)
            isValidLabel = ~ClassesMap.ShouldIgnoreLabels([eventAnnotations.label]);
            eventAnnotations = eventAnnotations(isValidLabel);
        end
                
        function goodEvents = computeGoodEvents(~,detectedEvents, isGoodEvent)
            nGoodEvents = sum(isGoodEvent);
            goodEvents = [];
            if nGoodEvents > 0
                goodEvents = repmat(Event(),1,nGoodEvents);
                goodEventCount = 1;
                for i = 1 : length(detectedEvents)
                    if isGoodEvent(i)
                        goodEvents(goodEventCount) = detectedEvents(i);
                        goodEventCount = goodEventCount + 1;
                    end
                end
            end
        end
        
        function badEvents = computeBadEvents(~,detectedEvents,isGoodEvent)
            nBadEvents = sum(~isGoodEvent);
            badEvents = [];
            if nBadEvents > 0
                badEvents = repmat(Event(),1,nBadEvents);
                eventCount = 1;
                for i = 1 : length(detectedEvents)
                    if ~isGoodEvent(i)
                        badEvents(eventCount) = detectedEvents(i);
                        eventCount = eventCount + 1;
                    end
                end
            end
        end
        
        function missedEvents = computeMissedEventAnnotations(obj,detectedEvents,eventAnnotations)
            didMissEvent = obj.computeDidMissEvent(detectedEvents,eventAnnotations);
            missedEvents = [];
            nMissedEvents = sum(didMissEvent);
            if nMissedEvents > 0
                missedEvents = repmat(EventAnnotation,1,nMissedEvents);
                missedEventCounter = 1;
                for i = 1 : length(didMissEvent)
                    if didMissEvent(i)
                        missedEvents(missedEventCounter) = eventAnnotations(i);
                        missedEventCounter = missedEventCounter + 1;
                    end
                end
            end
        end
        
        function didMissEvent = computeDidMissEvent(obj,detectedEvents,annotations)
            nEvents = length(annotations);
            if isempty(detectedEvents)
                didMissEvent = true(1,nEvents);
            else

                didMissEvent = false(1,nEvents);
                                
                detectedEventLocations = [detectedEvents.sample];
                
                segmentStartings = detectedEventLocations - obj.tolerance;
                segmentEndings = detectedEventLocations + obj.tolerance;
                                
                for i = 1 : length(annotations)
                    if obj.isRelevantLabel(annotations(i).label)
                        eventLocation = annotations(i).sample;
                        contained = Helper.isPointContainedInSegments(eventLocation,segmentStartings,segmentEndings);
                        if ~contained
                            didMissEvent(i) = true;
                        end
                    end
                end
            end
        end
    end
end

