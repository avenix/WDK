function result = myKurtosis(signal)

%meanComputer = dsp.Mean('RunningMean',false,'Dimension','All');
%signalMean = step(meanComputer,signal);
signalMean = mean(signal);

upper = single(0);
lower = single(0);

n = single(length(signal));

for i = 1 : n
    temp = single(signal(i) - signalMean);
    temp2 = single(temp * temp);
    upper = upper + temp2 * temp2;
    lower = lower + temp2;
end
lower = lower / n;
result = upper / (n*lower*lower);
end
