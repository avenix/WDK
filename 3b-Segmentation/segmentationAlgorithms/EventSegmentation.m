classdef EventSegmentation < Segmentation
    
    properties(Access = public)
        eventDetector;
        data;%set from outside, otherwise lazily loaded
    end
    
    methods (Access = public)
        
        function obj = EventSegmentation(eventDetector)
            if nargin == 1
                obj.eventDetector = eventDetector;
                obj.type = 'event-based';
            end
        end
        
        function resetVariables(obj)
            obj.resetVariables@Segmentation();
        end
        
        function outData = compute(obj,inData)
            outData = obj.segment(inData);
        end
        
        %returns unlabelled segments
        function segmentsPerFile = segment(obj,signalPerFile)
            
            if isempty(obj.data)
                dataLoader = DataLoader();
                obj.data = dataLoader.loadAllDataFiles();
            end
            
            nFiles = length(signalPerFile);
            segmentsPerFile = cell(1,nFiles);
            
            for i = 1 : nFiles
                signal = signalPerFile{i};
                dataFile = obj.data{i};
                segmentsPerFile{i} = obj.segmentFile(signal,dataFile);
            end
        end
        
        function str = toString(obj)
            eventDetectorStr = "detector";
            if ~isempty(obj.eventDetector)
                eventDetectorStr = obj.eventDetector.toString();
            end
            
            str = sprintf('%s%d%d',eventDetectorStr,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end
    
    methods (Access = private)
        
        function b = isValidInput(~,input)
            if isempty(input)
                b = true;
            else
                if isa(input(1),'EventAnnotation')
                    b = true;
                else
                    b = false;
                end
            end
            
        end
        
        function segments = segmentFile(obj,signal,dataFile)
            events = obj.eventDetector.compute(signal);
            
            if ~obj.isValidInput(events)
                fprintf('%s - EventSegmentation\n',Constants.kInvalidEventSegmentationInput);
                segments = [];
            else
                segments = obj.createSegmentsWithEvents(events,dataFile);
            end
        end
        
    end
    
end