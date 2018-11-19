classdef ManualSegmentation < Segmentation
    
    properties
        manualAnnotations;
    end
    
    methods (Access = public)
        function resetVariables(obj)
            resetVariables@Segmentation(obj);
        end
        
        %returns labeled segments
        function segments = segment(obj,data)
            eventAnnotations = obj.manualAnnotations.eventAnnotations;
            eventLocations = [eventAnnotations.sample];
            segments = obj.computeSegmentsBasedOnEvents(eventLocations,data);
            
            %label segments
            nSegments = length(segments);
            for i = 1 : nSegments
                segments(i).class = eventAnnotations(i).label;
            end
        end
        
        function str = toString(obj)
            str = sprintf('manual%d%d',obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end
end