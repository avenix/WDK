classdef AnnotationMarkersPlotter < handle
    properties (Access = private, Constant)    
        markerColors = {[1 0 0],[1 1 0],[0 1 0], [0 0 1], [0 1 1], [1 105/255 180/255], [0.5 0 0.5], [0 0 0]};
        markerLineWidths = [1,1,4,1,1,1,1,1];
    end
    
    properties (Access = public)
        markerYRange = [-1 1];
        markerHandles;
        shouldShowMarkers = true;
    end
    
    methods
        function set.shouldShowMarkers(obj,visible)
            obj.setMarkersVisibility(visible);
            obj.shouldShowMarkers = visible;
        end
    end
    
    methods (Access = public)
        
        function plotMarkers(obj, markers, plotAxes)
            
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
                    'LineStyle','-');
                
                if ~isempty(marker.text)
                    textY = double((obj.markerYRange(1) + obj.markerYRange(2)) / 2);
                    textHandle = text(plotAxes,double(marker.sample),...
                        textY , marker.text,...
                        'Rotation',90);
                    
                    set(textHandle, 'Clipping', 'on');
                    markerHandle.textHandle = textHandle;
                end
                
                obj.markerHandles(i) = markerHandle;
            end
            
            obj.setMarkersVisibility(obj.shouldShowMarkers);
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
            visibleStr = Helper.GetOnOffString(visible);
            for i = 1 : length(obj.markerHandles)
                markerHandle = obj.markerHandles(i);
                markerHandle.visible = visibleStr;
            end
        end
    end
    
end
