classdef SegmentationTestbedEventHandle < handle
    properties
        symbolHandle;
        textHandle;
    end
    
    properties (Access = private, Constant)
        visibleStringss = {'off','on'};
    end
    
    methods
        function obj = SegmentationTestbedEventHandle(symbolHandle, textHandle)
            if nargin > 1
                obj.symbolHandle = symbolHandle;
                obj.textHandle = textHandle;
            end
        end
        
        function setVisible(obj,visible)
            obj.peakSymbolHandle.Visible = obj.visibleStringss{visible+1};
            obj.peakTextHandle.Visible = obj.visibleStringss{visible+1};
        end
    end
end