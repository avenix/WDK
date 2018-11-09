function plotMarkers(markers, markerLabels)

%plot markers
markerColors = {[1 0 0],[1 1 0],[0 1 0], [0 0 1], [0 1 1], [1 105/255 180/255], [0.5 0 0.5], [0 0 0]};
for i = 1 : length(markers)
    timestamp = markers(i);
    
    markerLabel = markerLabels(i);
    color = markerColors(markerLabel);
    lineWidth = 1;
    lineHeight = 25000;
    if markerLabel == 3
        lineWidth = 4;
    end
    line([timestamp, timestamp+5],[0 lineHeight],'Color',color{1},'LineWidth',lineWidth);
end

end