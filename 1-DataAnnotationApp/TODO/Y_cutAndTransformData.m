%careful when runnign this script. It generates and saves data files to the
%file system

close all;

ACCEL_SCALE_FACTOR_16G = 1000 / 2048;
GYRO_SCALE_FACTOR_2000 = 1000 / 16.4;

%fileNames = {'8-alex','9-jakob','10-michi','11-roko','12-theo','13-aldin'};
fileName ='14-adrian';

%for i = 1 : length(fileNames)
%fileName = fileNames(i);
%fileName = fileName{1};

dataFileName = sprintf('%s-right',fileName);
dataStruct = load(dataFileName);
data = struct2array(dataStruct);

%convert accel and gyro
data(:,2) = data(:,2) * ACCEL_SCALE_FACTOR_16G;
data(:,3) = data(:,3) * ACCEL_SCALE_FACTOR_16G;
data(:,4) = data(:,4) * ACCEL_SCALE_FACTOR_16G;
data(:,5) = data(:,5) * GYRO_SCALE_FACTOR_2000;
data(:,6) = data(:,6) * GYRO_SCALE_FACTOR_2000;
data(:,7) = data(:,7) * GYRO_SCALE_FACTOR_2000;

%ts = data(:,1);
firstSample = 1;
%firstSample = find(ts == 85380);
lastSample = size(data,1);
%lastSample = find(ts == 1762820);
%data = data(firstSample:lastSample,:);

%magnitude= sqrt(data(:,2).^2+data(:,3).^2+data(:,4).^2);
%ts = data(:,1);
%figure
%plot(ts,magnitude);

save(dataFileName,'data');

%end