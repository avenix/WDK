classdef DataAnnotationMarkerHandle < handle
    properties
        lineHandle;
        textHandle;
    end
    
    methods
        function obj = DataAnnotationMarkerHandle(lineHandle,textHandle)
            if nargin ~= 0
                obj.lineHandle = lineHandle;
                obj.textHandle = textHandle;
            end
        end
        
    end
end
