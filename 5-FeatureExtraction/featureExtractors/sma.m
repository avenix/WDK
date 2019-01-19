% signal magnitude areas 
%
function res = sma(window)
res = sum(sum(abs(window)));
end