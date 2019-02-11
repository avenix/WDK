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

%only recompile all mex files when necessary
%makeosmex;

echo on;

a = [1 2 1 2 1]'; 
b = [2 1 2 1 1]';
c = [2 1 2 2 1]';

mutualinfo(a,b)
entropy(a)+condentropy(b)-jointentropy(a,b)
condentropy(a,b)
condentropy(a,c)
jointentropy(a,c)
mutualinfo(a,c)
condmutualinfo(a,c)
condmutualinfo(a,c,b)
condmutualinfo(a,c,[b c])

echo off;

