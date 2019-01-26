function [spf] = spectralFlatness(window)

pxx = periodogram(window);
num=geomean(pxx);
den=mean(pxx);
spf=num/den ;
end