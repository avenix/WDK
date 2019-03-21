classdef Segment < handle
    
    properties (Access = public)
        file;
        data;
        label;
        eventIdx;
        startSample;
        endSample;
    end
    
    methods (Access = public)
        function obj = Segment(file,data,label,eventIdx)
            if nargin > 3
                obj.file = file;
                obj.data = data;
                obj.label = label;
                obj.eventIdx = eventIdx;
            end
        end
    end
    
    methods (Static)
        %copies a segment (does not copy the data)
        function newSegment = CreateSegmentWithSegment(segment)
            newSegment = Segment(segment.file,[],segment.label,segment.eventIdx);
            newSegment.startSample = segment.startSample;
            newSegment.endSample = segment.endSample;
        end
    end
end

