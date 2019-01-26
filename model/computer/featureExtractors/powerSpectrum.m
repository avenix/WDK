%chose this among powerSpectralDensity2 and powerSpectralDensity3 based on
%smaller range (all of them seem to be a linear scaling of the same)
function result = powerSpectrum(data,fourierTransform)

N = length(data);
Y = optimizedFFT(data,fourierTransform);

result = ((sqrt(abs(Y).*abs(Y)) * 2 )/N);
result = result(1:floor(N/2));

end