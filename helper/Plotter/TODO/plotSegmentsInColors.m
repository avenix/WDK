function plotSegmentsInColors(data,classSegments, labelingStrategy, titleName)

figure();
hold on;

maxYValue = max(data);

%plot labels and separation lines
for i = 1 : length(classSegments)
    classSegment = classSegments(i);
    if classSegment > 0
        line([classSegment classSegment],[0 maxYValue], 'Color', 'red');
        className = labelingStrategy.classNames(i);
        text(classSegment,maxYValue,className);
    end
end

%generate colors array
classSegments = classSegments(classSegments > 0);
colors = strings(length(classSegments),1);
for i = 1 : length(classSegments) - 1
    if mod(i,2) == 0
        colors(i) = 'b';
    else
        colors(i) = 'c';
    end
end
colors(length(classSegments)) = 'm';%null class

%plot segments
for i = 1 : length(classSegments)
    segmentStart = classSegments(i);
    if i == length(classSegments)
        segmentEnd = length(data);
    else
        segmentEnd = classSegments(i+1);
    end
    
    color = colors(i);
    segment = data(segmentStart:segmentEnd);
    plot(segmentStart:segmentEnd,segment,'Color',color);
end

title(titleName);

end