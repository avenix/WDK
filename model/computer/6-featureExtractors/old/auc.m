function result = auc(signal,windowSize)
if ~exist('windowSize','var')
    windowSize = length(signal);
end
%integrates the signal 
result = 0;
for i = 0 : windowSize : length(signal)-1
    startIndex = i * windowSize + 1;
    endIndex = startIndex + windowSize;
    endIndex = min(endIndex,length(signal));
    window = signal(startIndex:endIndex);
    result = result + trapz(window);
end
end