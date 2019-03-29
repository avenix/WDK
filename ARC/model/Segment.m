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
            if nargin >= 1
                obj.file = file;
                if nargin >= 2
                    obj.data = data;
                    if nargin >= 3
                        obj.label = label;
                        if nargin >= 4
                            obj.eventIdx = eventIdx;
                        end
                    end
                end
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

