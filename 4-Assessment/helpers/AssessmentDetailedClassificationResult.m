%describres the results of a classification for a single file
classdef AssessmentDetailedClassificationResult < handle
    properties (Access = public)
        annotations;
        segments;
        classificationResult ClassificationResult;
        missedEvents;
    end
    
    properties (Dependent)
        fileName;
    end
    
    methods
        function fn = get.fileName(obj)
            fn = obj.classificationResult.table.file.fileName;
        end
    end
    
    methods (Access = public)
        function obj = AssessmentDetailedClassificationResult(annotations, segments,...
                classificationResult, postProcessingAlgorithm)
            if nargin > 0
                obj.annotations = annotations;
                obj.segments = segments;
                obj.classificationResult = classificationResult;
                obj.createMissedEvents(postProcessingAlgorithm);
            end
        end
        
        function labels = getAllTruthLabels(obj)
            labels = vertcat(obj.classificationResult.truthClasses);
        end
        
        function labels = getAllPredictedLabels(obj)
            labels = vertcat(obj.classificationResult.predictedClasses);
        end
    end
    
    methods (Access = private)
        function createMissedEvents(obj,postProcessingAlgorithm)
            if obj.shouldUseEventDetection()
                resultsComputer = DetectionResultsComputer();
                events = obj.createEventsWithEventIdxs(obj.segments);
                detectionResults = resultsComputer.computeDetectionResults({events},obj.annotations);
                obj.missedEvents = detectionResults.missedEvents;
                if isa(postProcessingAlgorithm, 'LabelMapper')
                    obj.mapMissedEvents(postProcessingAlgorithm);
                    %obj.mapEventAnnotations(postProcessingAlgorithm);
                end
            end
        end
        
        function shouldUseEventDetection = shouldUseEventDetection(obj)
            shouldUseEventDetection = false;
            if ~isempty(obj.segments)
                firstSegment = obj.segments(1);
                shouldUseEventDetection = ~isempty(firstSegment.eventIdx);
            end
        end
        
        function events = createEventsWithEventIdxs(~,segments)
            nEvents = length(segments);
            events = repmat(Event,1,nEvents);
            for i = 1 : nEvents
                segment = segments(i);
                events(i) = Event(segment.eventIdx,segment.label);
            end
        end

        function mapMissedEvents(obj,labelMapper)
            for j = 1 : length(obj.missedEvents)
                obj.missedEvents(j).label = labelMapper.mappingForLabel(obj.missedEvents(j).label);
            end
        end
        
        %{
        function mapEventAnnotations(obj,labelMapper)
            for j = 1 : length(obj.annotations.eventAnnotations)
                eventAnnotation = obj.annotations.eventAnnotations(j);
                eventAnnotation.label = labelMapper.mappingForLabel(eventAnnotation.label);
                obj.annotations.eventAnnotations(j) = eventAnnotation;
            end
        end
        %}
    end
end