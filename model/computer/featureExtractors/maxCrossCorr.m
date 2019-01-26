function result = maxCrossCorr(signal1,signal2)
result = max(xcorr(signal1,signal2));
end