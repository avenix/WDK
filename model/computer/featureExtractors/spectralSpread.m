function [S] = spectralSpread(data,fourierTransform)

% function C = feature_spectral_centroid(window_FFT, fs)
%
% Computes the spectral spread of a frame
%
% ARGUMENTS:
% - window_FFT: the abs(FFT) of an audio frame
%               (computed by getDFT() function)
% - fs:         the sampling freq of the input signal (in Hz)
% 
% RETURNS:
% - S:          the value of the spectral spread 
%               (normalized in the 0..1 range)
%

fs = 100;

N = length(data); 
windowFFT = abs(optimizedFFT(data,fourierTransform)) / N;
windowFFT = windowFFT(1:ceil(N/2));  

windowLength = length(windowFFT);
m = ((fs/(2*windowLength))*(1:windowLength))';
windowFFT = windowFFT / max(windowFFT);

% compute the spectral spread
C = sum(m.*windowFFT)/ (sum(windowFFT)+eps);
S = sqrt(sum(((m-C).^2).*windowFFT)/ (sum(windowFFT)+eps));

S = S / (fs/2);

end