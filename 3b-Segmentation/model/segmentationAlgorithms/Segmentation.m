%each segmentation approach should return the starting and ending indices of each segment
classdef (Abstract) Segmentation < handle
    properties (Constant, Access = public)
        kBestSegmentSizeLeft = uint32(250);
        kBestSegmentSizeRight = uint32(200);
    end
    
    properties (Access = public)
        segmentSizeLeft;
        segmentSizeRight;
    end
    
    methods (Abstract)
        segments = segment(obj,data);
        str = toString(obj);
    end
    
    methods (Access = public)
        
        function obj = Segmentation()
            obj.resetVariables();
        end
        
        function resetVariables(obj)
            obj.segmentSizeLeft = Segmentation.kBestSegmentSizeLeft;
            obj.segmentSizeRight = Segmentation.kBestSegmentSizeRight;
        end
    end
    
    methods (Access = protected)
        function segments = computeSegmentsBasedOnEvents(obj,eventLocations, data)
            numSamples = size(data,1);
            segmentStartings = eventLocations - obj.segmentSizeLeft;
            segmentEndings = eventLocations + obj.segmentSizeRight;
            isValidSegment = (segmentStartings >= 1) | (segmentEndings <= numSamples);
            eventLocations = eventLocations(isValidSegment);
            
            segments = obj.createSegmentsWithEventLocations(eventLocations,data);
        end
        
        function [segmentStarting, segmentEnding] = computeSegmentForPeak(obj,peakLocation)
            segmentStarting = peakLocation - uint32(obj,obj.segmentSizeLeft);
            segmentEnding = peakLocation + uint32(obj,obj.segmentSizeRight);
        end
        
        function segments = createSegmentsWithEventLocations(obj,eventLocations,data)
            nSegments = length(eventLocations);
            segments = repmat(Segment,1,nSegments);
            for i = 1 : nSegments
                eventLocation = eventLocations(i);
                segment = Segment();
                segment.peakIdx = eventLocation;
                segment.startSample = eventLocation - obj.segmentSizeLeft;
                segment.endSample =  eventLocation + obj.segmentSizeRight;
                segment.window = data(segment.startSample:segment.endSample,:);
                segments(i) = segment;
            end
        end
    end
    
end