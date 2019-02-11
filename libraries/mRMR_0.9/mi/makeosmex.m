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
%
%batch compiling of the mex files from cpp src
%by Hanchuan Peng
%April/16/2002

list = dir('*.cpp');

for i=1:length(list),

  fprintf('building mex(dll) of %s\n',list(i).name);
  mex(list(i).name);

end;
