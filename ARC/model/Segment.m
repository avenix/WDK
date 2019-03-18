classdef Segment < handle
    
    properties (Access = public)
        file;
        window;
        label;
        eventIdx;
        startSample;
        endSample;
    end
    
    methods (Access = public)
        function obj = Segment(file,window,label,eventIdx)
            if nargin > 3
                obj.file = file;
                obj.window = window;
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

