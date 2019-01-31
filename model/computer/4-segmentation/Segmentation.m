%each segmentation approach should return the starting and ending indices of each segment
classdef (Abstract) Segmentation < Computer
    
    properties (Access = public)
        segmentSizeLeft = 250;
        segmentSizeRight = 200;
    end
    
    methods (Access = public)
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('segmentSizeLeft',obj.segmentSizeLeft);
            property2 = Property('segmentSizeRight',obj.segmentSizeRight);
            editableProperties = [property1,property2];
        end
    end
    
    methods (Access = protected)
        function segments = createSegmentsWithEvents(obj,events,data)
            nSegments = obj.countNumValidSegments(events,data);
            segments = repmat(Segment,1,nSegments);
            nSamples = length(data);
            segmentsCounter = 0;
            
            for i = 1 : length(events)
                eventLocation = events(i).sample;
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
        
        function numValidSegments = countNumValidSegments(obj,events,data)
            nSamples = length(data);
            numValidSegments = 0;
            for i = 1 : length(events)
                eventLocation = events(i).sample;
                startSample = int32(eventLocation) - int32(obj.segmentSizeLeft);
                endSample = int32(eventLocation) + int32(obj.segmentSizeRight);
                if startSample > 0 && endSample <= nSamples
                    numValidSegments = numValidSegments + 1;
                end
            end
        end
    end
end