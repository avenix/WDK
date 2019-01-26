%returns the first component of the frequency representation of the signal
function res = dc(data,fourierTransform)

Y = optimizedFFT(data,fourierTransform);
res = real(Y(1));

end