function [fea] = mrmr_mibase_d(d, f, K)
% function [fea] = mrmr_mibase_d(d, f, K)
% 
% Baseline for comparing MRMR
%
% By Hanchuan Peng
% April 16, 2003
%

nd = size(d,2);
nc = size(d,1);

t1=cputime;
for i=1:nd, 
   t(i) = mutualinfo(d(:,i), f);
end; 
fprintf('calculate the marginal dmi costs %5.1fs.\n', cputime-t1);

[tmp, idxs] = sort(-t);
fea= idxs(1:K);


