%runs a custom peak detection, returns the peakLocations as an
%array.
function [peakLocations, lastPeakLocation, lastPeakValue] = findPeakLocations(magnitude,...
    minPeakHeight, minPeakDistance, lastPeakLocation, lastPeakValue) %#codegen
numPeakLocations = uint8(0);
peakLocations = int32(zeros(1,floor(length(magnitude) / minPeakDistance)));

for i = 1 : length(magnitude)
    sample = magnitude(i);
    
    if sample >= minPeakHeight
        if sample > lastPeakValue || i >= (lastPeakLocation + minPeakDistance)
            lastPeakValue = sample;
            lastPeakLocation = int32(i);
        end
    end
    
    if lastPeakValue > single(0.00001) && i >= lastPeakLocation + minPeakDistance
        lastPeakValue = single(0);
        numPeakLocations = numPeakLocations + 1;
        peakLocations(numPeakLocations) = lastPeakLocation;
    end
end
peakLocations = peakLocations(1:numPeakLocations);
end