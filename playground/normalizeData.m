dataLoader = DataLoader();
dataFiles = dataLoader.loadAllDataFiles();


for i = 1 : length(dataFiles)
    dataFile = dataFiles(i);
    dataFile.data = array2table([dataFile.data(:,3:5) / 156.8,...
        dataFile.data(:,6:8) / 2000.748,...
        dataFile.data(:,9:11) / 50,...
        dataFile.data(:,[12,13,14,18]),...
        dataFile.data(:,15:17) / 16]);
    dataFile.data.Properties.VariableNames =  {'ax','ay','az','gx','gy','gz','mx','my','mz','q0','q1','q2','q3','lax','lay','laz'};
    dataLoader.saveData(dataFile.data,Helper.removeFileExtension(dataFile.fileName));
end
