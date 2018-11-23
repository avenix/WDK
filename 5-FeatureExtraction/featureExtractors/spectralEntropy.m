%decided for this compared to spectralEntropy2 and spectralEntropy based on
%its simplicify and visually comparing the entropies of each class
%(see images entropy1.png, %entropy2.png and entropy3.png)

function result = spectralEntropy(data,fourierTransform)

powerSpectrumResult = powerSpectrum(data,fourierTransform);

%Normalization
maxPower = sum(powerSpectrumResult + 1e-12);
powerSpectrumResult = powerSpectrumResult / maxPower;

%entropy calculation
result = -sum(powerSpectrumResult.*log2(powerSpectrumResult+eps));

end