classdef EventSegmentation < Segmentation
    
    properties
        eventDetector;
        signalComputer;
    end
    
    methods (Access = public)
        
        function obj = EventSegmentation(eventDetector)
            if nargin == 1
                obj.eventDetector = eventDetector;
            end
        end
        
        function resetVariables(obj)
            obj.resetVariables@Segmentation();
        end
        
        %returns unlabelled segments
        function segments = segment(obj,data)
            signal = obj.signalComputer.compute(data);
            events = obj.eventDetector.detectPeaks(signal);
            segments = obj.computeSegmentsBasedOnEvents(events,data);
        end
        
        function str = toString(obj)
            eventDetectorStr = obj.eventDetector.toString();
            str = sprintf('%s_%d_%d',eventDetectorStr,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end    
end