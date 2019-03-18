classdef AnnotationMarkerHandle < handle
    properties
        lineHandle;
        textHandle;
    end
    
    properties (Dependent)
        visible;
    end
    
    methods
        function set.visible(obj,visibleStr)
            obj.textHandle.Visible = visibleStr;
            obj.lineHandle.Visible = visibleStr;
        end
    end
    
    methods (Access = public)
        function obj = AnnotationMarkerHandle(lineHandle,textHandle)
            if nargin ~= 0
                obj.lineHandle = lineHandle;
                obj.textHandle = textHandle;
            end
        end
    end
end
