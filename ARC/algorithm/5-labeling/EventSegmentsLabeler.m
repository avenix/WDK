%labels segments comparing their eventIdx property to event annotations. 
%The eventIdx prperty is set if an eventSegmentation has been used 
%to generate the segment
classdef EventSegmentsLabeler < Computer
    
    properties (Access = public)
        manualAnnotations;
    end
    
    methods (Access = public)
        
        function obj = EventSegmentsLabeler()
            obj.name = 'eventSegmentsLabeler';
            obj.inputPort = DataType.kSegment;
            obj.outputPort = DataType.kSegment;
        end
        
        function labeledSegments = compute(obj,segments)
            eventsLabeler = EventsLabeler();
            labels = eventsLabeler.labelEventIdxs([segments.eventIdx],obj.manualAnnotations.eventAnnotations);
            
            labeledSegments = Helper.LabelSegmentsWithValidLabels(segments,labels);
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
    end
end
