classdef DetectionEventHandle < handle
    properties
        detectedEvent;
        symbolHandle;
        textHandle;
    end
    
    properties (Access = private, Constant)
        visibleStringss = {'off','on'};
    end
    
    methods (Access = public)
        function obj = DetectionEventHandle(detectedEvent,symbolHandle, textHandle)
            if nargin > 0
                obj.detectedEvent = detectedEvent;
                obj.symbolHandle = symbolHandle;
                obj.textHandle = textHandle;
            end
        end
        
        function setVisible(obj,visible)
            obj.symbolHandle.Visible = obj.visibleStringss{visible+1};
            obj.textHandle.Visible = obj.visibleStringss{visible+1};
        end
    end
end