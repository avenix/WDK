classdef EventSegmentsLabeler < Computer
    
    methods (Access = public)
        
        function obj = EventSegmentsLabeler()
            obj.name = 'eventSegmentsLabeler';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function labeledSegments = compute(~,segments)
            manualAnnotations = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentAnnotationFile);
            eventsLabeler = EventsLabeler();
            labels = eventsLabeler.labelEventIdxs([segments.eventIdx],manualAnnotations.eventAnnotations);
            isValidLabel = ~ClassesMap.ShouldIgnoreLabels(labels);
            
            nValidSegments = sum(isValidLabel);
            labeledSegments = repmat(Segment,1,nValidSegments);
            segmentCounter = 1;
            
            for i = 1 : length(segments)
                segment = segments(i);
                if isValidLabel(i)
                    segment.label = labels(i);
                    labeledSegments(segmentCounter) = segment;
                    segmentCounter = segmentCounter + 1;
                end
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
    end
end