%Data around the peak
classdef Segment < handle
    
    properties
        file %TODO see if we can remove
        window
        class
        peakIdx
        startSample;
        endSample;
    end
    
    methods
        function obj = Segment(file,window,class,peakIdx)
            if nargin > 3 %enable initialisation with no params
                obj.file = file;
                obj.window = window;
                obj.class = class;
                obj.peakIdx = peakIdx;
            end
        end
    end
end

