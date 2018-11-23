% signal magnitude areas 
%
function res = SMA(window)
res = sum(sum(abs(window)));
end