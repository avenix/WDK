
classdef EventAnnotation < handle
    properties
        sample;
        label;
    end
    
    methods
        function obj = EventAnnotation(sample,label)
            if nargin>1
                obj.sample = sample;
                obj.label = label;
            end
        end
    end
end