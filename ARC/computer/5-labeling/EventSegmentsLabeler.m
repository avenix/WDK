%labels segments comparing their eventIdx property to event annotations. 
%The eventIdx prperty is set if an eventSegmentation has been used 
%to generate the segment
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
            
            labeledSegments = Helper.LabelSegmentsWithValidLabels(segments,labels);
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
    end
end