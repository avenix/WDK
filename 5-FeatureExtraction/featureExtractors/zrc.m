function result = zrc(data)
N = length(data);
result = sum(abs(diff(data>0))) / N;
end