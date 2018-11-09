fileName ='8-alex';
dataFileName = sprintf('%s-right',fileName);
dataStruct = load(dataFileName);
data = struct2array(dataStruct);
ts = data(:,1);

firstSample = find(ts == 1531980);
lastSample = find(ts == 1848380);

data(firstSample:lastSample,2:7) = 0;

magnitude= sqrt(data(:,2).^2+data(:,3).^2+data(:,4).^2);

figure
plot(ts,magnitude);
save(fileName,'data');