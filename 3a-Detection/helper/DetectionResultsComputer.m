%computes an array of DetectionResults (which contain arrays of labelled events: goodEvents, missedEvents, badEvents) per
%file
classdef DetectionResultsComputer < handle
    properties
        tolerance = 10;
        labelingStrategy;
        classesMap;
    end
    
    methods (Access = public)
        
        function obj = DetectionResultsComputer()
            obj.classesMap = ClassesMap.instance();
        end
        
        %returns an array of DetectionResults (one for each file)
        function detectionResults = computeDetectionResults(obj,eventsCellArray,annotationsCellArray)
            if isempty(obj.labelingStrategy)
                fprintf('%s\n',Constants.kLabelingStrategyNotSetWarning);
            else
                
                nCells = length(eventsCellArray);
                detectionResults(1,nCells) = DetectionResult();
                for i = 1 : nCells
                    annotationSet = annotationsCellArray(i);
                    detectedEvents = eventsCellArray{i};
                    detectionResults(i) = obj.computeDetectionResultsForFile(detectedEvents,annotationSet.eventAnnotations);
                end
            end
        end
    end
    
    methods (Access = private)
        
        function detectionResult = computeDetectionResultsForFile(obj,detectedEventLocations,eventAnnotations)
            
            labeler = EventsLabeler(obj.labelingStrategy);
            labeler.tolerance = obj.tolerance;
            labels = labeler.label(detectedEventLocations, eventAnnotations);
            invalidIdxs = labeler.getInvalidLabels(labels);
            
            detectedEventLocations = detectedEventLocations(~invalidIdxs);
            labels = labels(~invalidIdxs);

            isGoodEvent = obj.labelingStrategy.isRelevantLabel(labels);
            goodEvents = obj.computeGoodEvents(isGoodEvent,labels,detectedEventLocations);
            badEvents = obj.computeBadEvents(detectedEventLocations,isGoodEvent,labels);
            missedEvents = obj.computeMissedEvents(detectedEventLocations,eventAnnotations);
            
            detectionResult = DetectionResult(goodEvents,missedEvents,badEvents);
        end
        
        function goodEvents = computeGoodEvents(~,isGoodEvent,labels,detectedEventLocations)
            nGoodEvents = sum(isGoodEvent);
            goodEvents = [];
            if nGoodEvents > 0
                goodEvents = repmat(EventAnnotation(),1,nGoodEvents);
                goodEventIdx = 1;
                for i = 1 : length(detectedEventLocations)
                    if isGoodEvent(i)
                        eventLocation = detectedEventLocations(i);
                        label = labels(i);
                        goodEvents(goodEventIdx) = EventAnnotation(eventLocation,label);
                        goodEventIdx = goodEventIdx + 1;
                    end
                end
            end
        end
        
        function badEvents = computeBadEvents(obj,detectedEventLocations,isGoodEvent, classes)
            nSynchronisationInstances = sum(classes == obj.classesMap.synchronisationClass);
            nBadEvents = sum(~isGoodEvent) - nSynchronisationInstances;
            badEvents = [];
            if nBadEvents > 0
                badEvents = repmat(EventAnnotation(),1,nBadEvents);
                nullClass = obj.labelingStrategy.nullClass;
                badEventIdx = 1;
                for i = 1 : length(detectedEventLocations)
                    class = classes(i);
                    if ~isGoodEvent(i) && class ~= obj.classesMap.synchronisationClass
                        eventLocation = detectedEventLocations(i);
                        badEvents(badEventIdx) = EventAnnotation(eventLocation,nullClass);
                        badEventIdx = badEventIdx + 1;
                    end
                end
            end
        end
        
        function missedEvents = computeMissedEvents(obj,detetedEventLocations,annotations)
            didMissEvent = computeDidMissEvent(obj,detetedEventLocations,annotations);
            missedEvents = [];
            nMissedEvents = sum(didMissEvent);
            if nMissedEvents > 0
                missedEvents = repmat(EventAnnotation,1,nMissedEvents);
                missedEventCounter = 0;
                for i = 1 : length(didMissEvent)
                    if didMissEvent(i)
                        annotation = annotations(i);
                        class = annotation.label;
                        label = obj.labelingStrategy.labelForClass(class);
                        eventLocation = annotation.sample;
                        missedEventCounter = missedEventCounter + 1;
                        missedEvents(missedEventCounter) = EventAnnotation(eventLocation,label);
                    end
                end
            end
        end

        function didMissEvent = computeDidMissEvent(obj,detectedEventLocations,annotations)
            nEvents = length(annotations);
            didMissEvent = false(1,nEvents);
            
            segmentStartings = detectedEventLocations - obj.tolerance;
            segmentEndings = detectedEventLocations + obj.tolerance;
            for i = 1 : length(annotations)
                annotation = annotations(i);
                class = annotation.label;
                if class ~= obj.classesMap.synchronisationClass
                    label = obj.labelingStrategy.labelForClass(class);
                    if obj.labelingStrategy.isRelevantLabel(label)
                        eventLocation = annotation.sample;
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

