classdef EventSegmentation < Segmentation
    
    properties
        eventDetector;
    end
    
    methods (Access = public)
        
        function obj = EventSegmentation(eventDetector)
            if nargin == 1
                obj.eventDetector = eventDetector;
                obj.type = 'event';
            end
        end
        
        function resetVariables(obj)
            obj.resetVariables@Segmentation();
        end
        
        function outData = compute(obj,inData)
            outData = obj.segment(inData);
        end
        
        %returns unlabelled segments
        function segments = segment(obj,signal)
            events = obj.eventDetector.detectEvents(signal);
            segments = obj.createSegmentsWithEvents(events,signal);
        end
        
        function str = toString(obj)
            eventDetectorStr = "detector";
            if ~isempty(obj.eventDetector)
                eventDetectorStr = obj.eventDetector.toString();
            end
            
            str = sprintf('%s%d%d',eventDetectorStr,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end
    
    methods (Access = protected)
        function segmentsPerFile = createSegmentsPerFile(obj,dataFiles)
            
            nFiles = length(dataFiles);
            segmentsPerFile = cell(1,nFiles);
            
            for i = 1 : nFiles
                dataFile = dataFiles{i};
                segmentsPerFile{i} = obj.segment(dataFile);
            end
        end
    end
end