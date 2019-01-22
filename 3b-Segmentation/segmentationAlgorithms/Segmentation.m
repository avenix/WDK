%each segmentation approach should return the starting and ending indices of each segment
classdef (Abstract) Segmentation < Computer
    properties (Constant, Access = public)
        kBestSegmentSizeLeft = uint32(250);
        kBestSegmentSizeRight = uint32(200);
    end
    
    properties (Access = public)
        segmentSizeLeft;
        segmentSizeRight;
        type;
    end
    
    methods (Abstract, Access = public)
        segments = segment(obj,signalPerFile);
        str = toString(obj);
    end
    
    methods (Access = public)
        
        function obj = Segmentation()
            obj.resetVariables();
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('segmentSizeLeft',obj.segmentSizeLeft);
            property2 = Property('segmentSizeRight',obj.segmentSizeRight);
            editableProperties = [property1,property2];
        end
        
        function outData = compute(obj,inData)
            outData = obj.segmentFiles(inData);
        end
        
        function resetVariables(obj)
            obj.segmentSizeLeft = Segmentation.kBestSegmentSizeLeft;
            obj.segmentSizeRight = Segmentation.kBestSegmentSizeRight;
        end
    end
    
    methods (Access = protected)
        function segments = createSegmentsWithEvents(obj,eventLocations,data)
            nSegments = obj.countNumValidSegments(eventLocations,data);
            segments = repmat(Segment,1,nSegments);
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
                    segment.window = data(segment.startSample : segment.endSample,:);
                    segmentsCounter = segmentsCounter + 1;
                    segments(segmentsCounter) = segment;
                end
            end
        end
    end
    
    methods (Access = private)
        
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