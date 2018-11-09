function plotRelevantPeaks(data, peakLocations)

ts = data(:,1);
[peakTs, peakIdx] = intersect(ts,peakLocations);
magnitude = sqrt(data(:,2).^2+data(:,3).^2+data(:,4).^2);
plot(peakTs,magnitude(peakIdx),'*','Color','green');

end