function [C] = spectralCentroid(data,fourierTransform)

% function C = feature_spectral_centroid(window_FFT, fs)
%
% Computes the spectral centroid and spread of a frame
%
% ARGUMENTS:
% - window_FFT: the abs(FFT) of an audio frame
%               (computed by getDFT() function)
% - fs:         the sampling freq of the input signal (in Hz)
% 
% RETURNS:
% - C:          the value of the spectral centroid
%               (normalized in the 0..1 range)


N = length(data); 
%windowFFT = abs(fft(data)) / N;
windowFFT = abs(optimizedFFT(data,fourierTransform)) / N;
windowFFT = windowFFT(1:ceil(N/2));  

fs = 100;

windowLength = length(windowFFT);
m = ((fs/(2*windowLength))*(1:windowLength))';
windowFFT = windowFFT / max(windowFFT);

C = sum(m.*windowFFT)/ (sum(windowFFT)+eps);

% normalize by fs/2 (so that 1 correponds to the maximum signal frequency, i.e. fs/2):
C = C / (fs/2);

end