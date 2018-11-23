function res = featureMean(signal)
global SEGMENT_SIZE

res = single(0);
for i = 1 : SEGMENT_SIZE
    res = res + signal(i);
end

res = res / single(SEGMENT_SIZE);
end