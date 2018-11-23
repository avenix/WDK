%each segmentation approach should return the starting and ending indices of each segment
classdef (Abstract) Segmentation < handle
    properties (Constant, Access = public)
        kBestSegmentSizeLeft = uint32(250);
        kBestSegmentSizeRight = uint32(200);
    end
    
    properties (Access = public)
        segmentSizeLeft;
        segmentSizeRight;
        data;%set from outside, otherwise lazily loaded
    end
    
    methods (Abstract, Access = public)
        segments = segment(obj,data);
        
        str = toString(obj);
    end
    
    methods (Abstract, Access = protected)
        segmentsPerFile = createSegmentsPerFile(obj,dataFiles);
    end
    
    methods (Access = public)
        
        function obj = Segmentation()
            obj.resetVariables();
        end
        
        function segmentsPerFile = segmentFiles(obj,dataFiles)
            
            segmentsPerFile = obj.createSegmentsPerFile(dataFiles);
            
            if isempty(obj.data)
                dataLoader = DataLoader();
                obj.data = dataLoader.loadAllDataFiles();
            end
            
            obj.addDataToSegments(segmentsPerFile);
        end
        
        function resetVariables(obj)
            obj.segmentSizeLeft = Segmentation.kBestSegmentSizeLeft;
            obj.segmentSizeRight = Segmentation.kBestSegmentSizeRight;
        end
    end
    
    methods (Access = protected)
        function segments = createSegmentsWithEvents(obj,eventLocations, data)
            numValidSegments = obj.countNumValidSegments(eventLocations,data);
            segments = repmat(Segment,1,numValidSegments);
            nSamples = length(data);
            segmentsCounter = 0;
            
            for i = 1 : length(eventLocations)
                eventLocation = eventLocations(i);
                startSample = int32(eventLocation) - int32(obj.segmentSizeLeft);
                endSample = int32(eventLocation) + int32(obj.segmentSizeRight);
                
                if startSample > 0 && endSample <= nSamples
                    segment = Segment();
                    segment.eventIdx = eventLocation;
                    segment.startSample = uint32(startSample);
                    segment.endSample = uint32(endSample);
                    segment.window = data(segment.startSample:segment.endSample,:);
                    segmentsCounter = segmentsCounter + 1;
                    segments(segmentsCounter) = segment;
                end
            end
        end
    end
    
    methods (Access = private)
        
        
        function addDataToSegments(obj,segments)
            
            nFiles = length(segments);
            for i = 1 : nFiles
                segmentsCurrentFile = segments{i};
                dataCurrentFile = obj.data{i};
                for j = 1 : length(segmentsCurrentFile)
                    segment = segmentsCurrentFile(j);
                    segment.window = dataCurrentFile(segment.startSample:segment.endSample,:);
                end
            end
        end
        
        function numValidSegments = countNumValidSegments(obj,eventLocations,data)
            nSamples = length(data);
            numValidSegments = 0;
            for i = 1 : length(eventLocations)
                eventLocation = eventLocations(i);
                startSample = int32(eventLocation) - int32(obj.segmentSizeLeft);
                endSample = int32(eventLocation) + int32(obj.segmentSizeRight);
                if startSample > 0 && endSample <= nSamples
                    numValidSegments = numValidSegments + 1;
                end
            end
        end
    end
end