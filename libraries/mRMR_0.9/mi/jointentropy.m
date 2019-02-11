function h = jointentropy(vec1,vec2)
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
% h = jointentropy(vec1,vec2)
% calculate the joint entropy of two variables
%
% when only one variable presents, this function equals entropy(vec1)
%
% demo: 
%  a=[1 2 1 2 1]';b=[2 1 2 1 1]';
%  fprintf('jointentropy(a,b)= %d \n',jointentropy(a,b));
%
% By Hanchuan Peng, April/2002
%

if nargin<1,

  disp('Usage: h = condentropy(vec1,<vec2>).');
  h = -1;

elseif nargin<2,

  [p1] = estpa(vec1);
  h = estentropy(p1);

else,

  [p12] = estpab(vec1,vec2);
  h = estjointentropy(p12);

end;


