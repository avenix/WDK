%% maximum frequency
function maxFrequency = maximumFrequency(signal,fourierTransform)
signalLength = length(signal);
Fs = 1000;
frequency = Fs*(0:(signalLength/2))/signalLength;
endIndex = round(signalLength / 2 + 1);

P2 = abs(optimizedFFT(signal,fourierTransform)/signalLength);
P1 = P2(1:endIndex);
P1(2:end-1) = 2*P1(2:end-1);
[~, maxIndex] = max(P1);
maxFrequency = frequency(maxIndex);
end