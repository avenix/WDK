classdef DataAnnotatorMarkerHandle < handle
    properties
        lineHandle;
        textHandle;
    end
    
    methods
        function obj = DataAnnotatorMarkerHandle(lineHandle,textHandle)
            if nargin ~= 0
                obj.lineHandle = lineHandle;
                obj.textHandle = textHandle;
            end
        end
        
    end
end
