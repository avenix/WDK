classdef EventSegmentation < Segmentation
    
    properties
        peakDetector;
        signalComputer;
    end
    
    methods (Access = public)
        
        function obj = EventSegmentation(peakDetector)
            if nargin == 1
                obj.peakDetector = peakDetector;
            end
        end
        
        function resetVariables(obj)
            obj.resetVariables@Segmentation();
        end
        
        %returns unlabelled segments
        function segments = segment(obj,data)
            signal = obj.signalComputer.compute(data);
            events = obj.peakDetector.detectPeaks(signal);
            segments = obj.computeSegmentsBasedOnEvents(events,data);
        end
        
        function str = toString(obj)
            peakDetectorStr = obj.peakDetector.toString();
            str = sprintf('%s_%d_%d',peakDetectorStr,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end    
end