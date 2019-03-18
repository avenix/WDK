classdef AnnotationMarkersPlotter < handle
    properties (Access = public)
        markerHandles;
        markerColors = {[1 0 0],[1 1 0],[0 1 0], [0 0 1], [0 1 1], [1 105/255 180/255], [0.5 0 0.5], [0 0 0]};
        markerLineWidths = [1,1,4,1,1,1,1,1];
        markerYRange = [-1 1];
    end
    
    methods (Access = public)
        
        function plotMarkers(obj, markers, plotAxes, visible)
            if nargin == 3
                visible = true;
            end
            
            visibleStr = Helper.GetVisibleStr(visible);
            nMarkers = length(markers);
            obj.markerHandles = repmat(AnnotationMarkerHandle,1,nMarkers);
                        
            for i = 1 : length(markers)
                marker = markers(i);
                color = obj.markerColors(marker.label);
                lineWidth = obj.markerLineWidths(marker.label);
                
                markerHandle = AnnotationMarkerHandle();
                
                markerHandle.lineHandle = line(plotAxes,[marker.sample, marker.sample],...
                    [obj.markerYRange(1) obj.markerYRange(2)],...
                    'Color',color{1},'LineWidth',lineWidth,...
                    'LineStyle','-','Visible',visibleStr);
                
                if ~isempty(marker.text)
                    textY = double((obj.markerYRange(1) + obj.markerYRange(2)) / 2);
                    textHandle = text(plotAxes,double(marker.sample),...
                        textY , marker.text,...
                        'Rotation',90, 'Visible',visibleStr);
                    
                    set(textHandle, 'Clipping', 'on');
                    markerHandle.textHandle = textHandle;
                end
                
                obj.markerHandles(i) = markerHandle;
            end
        end
        
        function deleteMarkers(obj)
            
            for i = 1 : length(obj.markerHandles)
                markerHandle = obj.markerHandles(i);
                delete(markerHandle.lineHandle);
                delete(markerHandle.textHandle);
            end
            obj.markerHandles = [];
        end
        
        function setMarkersVisibility(obj,visible)
            visibleStr = Helper.GetVisibleStr(visible);
            for i = 1 : length(obj.markerHandles)
                markerHandle = obj.markerHandles(i);
                markerHandle.visible = visibleStr;
            end
        end
    end
    
end
