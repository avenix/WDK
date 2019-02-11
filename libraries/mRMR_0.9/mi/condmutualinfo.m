function h = condmutualinfo(vec1,vec2,condvec)
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
% h = condmutualinfo(vec1,vec2,condvec)
% calculate the mutual information of two vectors given the condvec
%
% if condvec is empty of nargin<3, then equals to mutualinfo.m
%
% example:
%  a=[1 2 1 2 1]';b=[2 1 2 1 1]';c=[2 1 2 2 1]'; 
%  condmutualinfo(a,b,c)
%  condmutualinfo(a,b,[c c])
%  condmutualinfo(a,b,[c a])
%  condmutualinfo(b,a,c)
%  condmutualinfo(b,a)   
%
% By Hanchuan Peng, April/2002
%

if nargin<3,
  condvec = [];
end;

if size(condvec,2)>1,
  newcondvec_z = mergemultivariables(condvec);
else %including the case of condvec=[]
  newcondvec_z = condvec;
end;

if isempty(newcondvec_z),
  h = condentropy(vec2) - condentropy(vec2,vec1);
else
  newcondvec_xz = mergemultivariables(newcondvec_z,vec1);
  h = condentropy(vec2,newcondvec_z) - condentropy(vec2,newcondvec_xz);
end;


