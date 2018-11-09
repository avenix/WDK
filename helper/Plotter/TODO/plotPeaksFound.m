%comapres manualPeakLocations to peakLocations and plots matches as green
function plotPeaksFound(data, manualPeakLocations, peakLocations)

ts = data(:,1);
magnitude = sqrt(data(:,2).^2+data(:,3).^2+data(:,4).^2);

plot(ts,magnitude);
hold on

[foundPeaks, ~] = intersect(manualPeakLocations,peakLocations);
[~, peakIdx] = intersect(ts,foundPeaks);
plot(foundPeaks,magnitude(peakIdx),'*','Color','green');

missingPeaks = setdiff(manualPeakLocations,peakLocations);
[~, peakIdx] = intersect(ts,missingPeaks);
plot(missingPeaks,magnitude(peakIdx),'o','Color','red');

falsePositivePeaks = setdiff(peakLocations,manualPeakLocations);
[~, peakIdx] = intersect(ts,falsePositivePeaks);
plot(falsePositivePeaks,magnitude(peakIdx),'*','Color','yellow');

end