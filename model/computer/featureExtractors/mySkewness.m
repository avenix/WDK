function result = mySkewness(signal)

%meanComputer = dsp.Mean('RunningMean',false,'Dimension','All');
%signalMean = step(meanComputer,signal);
signalMean = mean(signal);

n = single(length(signal));

upper = single(0);
lower = single(0);
for i = 1 : n
    temp = single(signal(i) - signalMean);
    temp2 = single(temp * temp);
    upper = upper + temp2 * temp;
    lower = lower + temp2;
end
lower = lower / n;
result = upper / (n * lower^1.5);
end
