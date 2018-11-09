function plotSegments(segmentStartings, segmentEndings, data, segmentHeight)

ts = data(:,1);
for i = 1 : length(segmentStartings)
    lineStart = segmentStartings(i);
    lineEnd = segmentEndings(i);
    if lineStart > 0 && lineEnd <= length(ts)
        line([ts(lineStart) ts(lineStart)], [0 segmentHeight],'Color','red', 'LineWidth',1,'LineStyle','-.');
        line([ts(lineEnd) ts(lineEnd)], [0 segmentHeight],'Color','black', 'LineWidth',1,'LineStyle','--');
    end
end

end