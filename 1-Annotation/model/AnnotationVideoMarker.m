classdef AnnotationVideoMarker < handle
    properties (Access = public)
        sample;
        label;
        text;
    end
    
    methods (Access = public)
        function obj = AnnotationVideoMarker(sample,label,text)
            if nargin ~= 0
                obj.sample = sample;
                obj.label = label;
                obj.text = text;
            end
        end
    end
end
