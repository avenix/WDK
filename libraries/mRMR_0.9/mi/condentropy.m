function h = condentropy(vec1,vec2)
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
% h = condentropy(vec1,vec2)
% calculate the entropy of a variable (vec1) or the conditional entropy of (vec1) given (vec2)
%
% demo: 
%  a=[1 2 1 2 1]';b=[2 1 2 1 1]';
%  fprintf('mi(a,b)= %d \n',mi(a,b));
%  fprintf('condentropy(a) - condentropy(a,b) = %d - %d = %d\n',...
%          condentropy(a),condentropy(a,b),condentropy(a)-condentropy(a,b));
%
% By Hanchuan Peng, April/2002
%

if nargin<1,

  disp('Usage: h = condentropy(vec1,<vec2>).');
  h = -1;

elseif nargin<2,

  [p1] = estpa(vec1);
  h = estentropy(p1);

else
  
  [p12, p1, p2] = estpab(vec1,vec2);
  h = estcondentropy(p12,p2);

end;


