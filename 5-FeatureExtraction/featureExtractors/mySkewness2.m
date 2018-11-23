function s = mySkewness2(x)
n = length(x);
dim = 1 ;
tile = [n 1];
x0 = x - repmat(mean(x,dim), tile);
s2 = mean(x0.^2,dim);
m3 = mean(x0.^3,dim);
s = m3 ./ s2.^(1.5);
end