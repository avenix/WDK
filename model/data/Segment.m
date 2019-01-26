classdef Segment < handle
    
    properties (Access = public)
        file;
        window;
        class;
        eventIdx;
        startSample;
        endSample;
    end
    
    methods (Access = public)
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

