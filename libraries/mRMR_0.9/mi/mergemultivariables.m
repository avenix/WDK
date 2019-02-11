function newvariable = mergemultivariables(variablearray1,variablearray2)
%=========================================================
%
%This is a prog in the MutualInfo 0.9 package written by 
% Hanchuan Peng.
%
%Disclaimer: The author of program is Hanchuan Peng
%      at <penghanchuan@yahoo.com> and <phc@cbmv.jhu.edu>.
%
%The CopyRight is reserved by the author.
%
%Last modification: April/19/2002
%
%========================================================
%
% function newvariable = mergemultivariables(variablearray1,variablearray2) 
%
% merge multi-variables as a new variable; each column of the avriable array
% is regarded as a variable
%
% example:
%  a=[1 2 1 2 1]';b=[2 1 2 1 1]';c=[2 1 2 2 1]'; 
%  t=mergemultivariables([a,c,b]),[a c b]
%
% By Hanchuan Peng
% April, 2002
%

if nargin<2,
  wholevarray = variablearray1;
else
  wholevarray = cat(2,variablearray1,variablearray2);
end;

if isempty(wholevarray),
    newvariable = [];
    return;
end;

newvariable = wholevarray(:,1);
for i=2:size(wholevarray,2),
  newvariable = findjointstateab(newvariable,wholevarray(:,i));
end;


