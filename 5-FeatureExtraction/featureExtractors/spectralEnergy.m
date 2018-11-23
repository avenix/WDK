function result = spectralEnergy(data,fourierTransform)
Y = optimizedFFT(data,fourierTransform);
N = length(Y);
Y = Y(1:ceil(N/2));
pow = Y.*conj(Y);
result = sum(pow) / N;
end