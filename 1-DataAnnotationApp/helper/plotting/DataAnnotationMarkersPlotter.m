classdef DataAnnotationMarkersPlotter < handle
    properties (Access = public)
        markerHandles;
        markerColors = {[1 0 0],[1 1 0],[0 1 0], [0 0 1], [0 1 1], [1 105/255 180/255], [0.5 0 0.5], [0 0 0]};
        markerLineWidths = [1,1,4,1,1,1,1,1];
    end
    
    methods (Access = public)
        
        function plotMarkers(obj, markers, plotAxes, visible)
            if nargin == 3
                visible = true;
            end
            
            visibleStr = DataAnnotationMarkersPlotter.getVisibleStr(visible);
            nMarkers = length(markers);
            obj.markerHandles = repmat(DataAnnotationMarkerHandle,1,nMarkers);
            
            markerHeights = ylim(plotAxes);
            
            for i = 1 : length(markers)
                marker = markers(i);
                color = obj.markerColors(marker.label);
                lineWidth = obj.markerLineWidths(marker.label);
                
                markerHandle = DataAnnotationMarkerHandle();
                
                markerHandle.lineHandle = line(plotAxes,[marker.sample, marker.sample],...
                    [markerHeights(1) markerHeights(2)],...
                    'Color',color{1},'LineWidth',lineWidth,...
                    'LineStyle','-','Visible',visibleStr);
                
                if ~isempty(marker.text)
                    textHandle = text(plotAxes,double(marker.sample-15),...
                        markerHeights(2) /2 , marker.text,...
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
        
        function toggleMarkersVisibility(obj,visible)
            visibleStr = MarkersPlotter.getVisibleStr(visible);
            for i = 1 : length(obj.markerHandles)
                markerHandle = obj.markerHandles(i);
                markerHandle.textHandle.Visible = visibleStr;
                markerHandle.lineHandle.Visible = visibleStr;
            end
        end
    end
    
    methods (Access = private, Static)
        function visibleStr = getVisibleStr(visible)
            visibleStr = 'off';
            if visible
                visibleStr = 'on';
            end
        end
    end
end
