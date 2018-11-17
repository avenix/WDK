%Data around the peak
classdef Segment < handle
    
    properties
        file %TODO see if we can remove
        window
        class
        eventIdx
        startSample;
        endSample;
    end
    
    methods
        function obj = Segment(file,window,class,eventIdx)
            if nargin > 3 %enable initialisation with no params
                obj.file = file;
                obj.window = window;
                obj.class = class;
                obj.eventIdx = eventIdx;
            end
        end
    end
end

