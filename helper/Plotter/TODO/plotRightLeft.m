close all;

fileName = '8-alex';
%fileName = '9-jakob';
%fileName = '10-michi';
%fileName = '11-roko';
%fileName = '12-teo';
%fileName = '13-aldin';
%fileName = '14-adrian';

rightDataFileName = sprintf('%s-right',fileName);
leftDataFileName = sprintf('%s-left',fileName);

rightData = load(rightDataFileName);
rightDataArray = struct2array(rightData);
rightMagnitude = sqrt(rightDataArray(:,2).^2+rightDataArray(:,3).^2+rightDataArray(:,4).^2);

leftData = load(leftDataFileName);
leftDataArray = struct2array(leftData);
leftMagnitude = sqrt(leftDataArray(:,2).^2+leftDataArray(:,3).^2+leftDataArray(:,4).^2);

figure();
subplot(2,1,1);
plot(rightDataArray(:,3));
axis([0 max(length(rightDataArray),length(leftDataArray)) -20000 40000]);
title('right');

subplot(2,1,2);
plot(leftDataArray(:,3));
xlim([0 max(length(rightDataArray),length(leftDataArray))]);
title('left');
axis([0 max(length(rightDataArray),length(leftDataArray)) -20000 40000]);

diff = abs(length(rightDataArray) - length(leftDataArray));
diffSec = diff / 100;
fprintf('size difference for %s: %.1f sec\n',fileName,diffSec);