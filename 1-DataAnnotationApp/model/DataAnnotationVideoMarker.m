classdef DataAnnotationVideoMarker < handle
    properties
        sample;
        label;
        text;
    end
    
    methods
        
        function obj = DataAnnotationVideoMarker(sample,label,text)
            if nargin ~= 0
                obj.sample = sample;
                obj.label = label;
                obj.text = text;
            end
        end
        
    end
end
