% Use it to save and load WDK files (data, annotations, markers,
% synchronisation and algorithms)
classdef DataLoader2 < handle
    
    methods (Static, Access = public)
        
        %% Data files
        
        %loads a binary data file. Full path should be specified
        function dataFile = LoadDataFileBinaryWithFullPath(~,fullPath)
            dataFile = load(fullPath);
            dataFile = dataFile.dataFile;
        end
        
        %loads a text data file. Full path should be specified
        function dataFile = LoadDataFileTextWithFullPath(~,fileName)
            tableImporter = TableImporter();
            data = tableImporter.importTable(fileName);
            columnNames = data.Properties.VariableNames;
            data = table2array(data);
            dataFile = DataFile(fileName,data,columnNames);
        end
        
        %loads a data file in text or binary format.  
        function dataFile = LoadDataFileBinary(fileName)
            fileName = sprintf('%s/%s',Constants.kDataPath,fileName);
            dataFile = obj.LoadDataFileBinaryWithFullPath(fileName);
        end
        
                %loads a data file in text or binary format. Full path should be specified
        function dataFile = LoadDataFile(fileName)
            fileExtension = Helper.getFileExtension(fileName);
            fileName = sprintf('%s/%s',Constants.kDataPath,fileName);
            if strcmp(fileExtension, ".mat")
                dataFile = LoadDataFileBinaryWithFullPath(fileName);
            elseif strcmp(fileExtension, ".txt")
                dataFile = LoadDataFileTextWithFullPath(fileName);
            else
                dataFile = [];
            end
        end
        
        %loads several data files
        function dataFiles = LoadDataFiles(fileNames)
            nDataFiles = length(fileNames);
            dataFiles = repmat(DataFile,1,nDataFiles);
            
            for i = 1 : length(fileNames)
                fileName = fileNames{i};
                dataFiles(i) = DataLoader.LoadDataFile(fileName);
            end
        end
        
        %saves a data file in binary format
        function SaveDataFileBinary(dataFile)
            save(dataFile.fileName,'dataFile');
        end
        
        %saves a data file in text format
        function data = SaveDataFileText(data,varNames,fileName)
            fileName = sprintf('%s.txt',fileName);
            
            tableExporter = TableExporter();
            table = array2table(data);
            if nargin > 2
                table.Properties.VariableNames = varNames;
            end
            tableExporter.exportTable(table,fileName);
        end
        
        %% Synchronization files
        
        function SaveSynchronizationFile(synchronizationFile,fileName)
            
            file = fopen(fileName,'w');
            if file > 0
                
                samples = synchronizationFile.synchronizationPointsMap.values;
                frames = synchronizationFile.synchronizationPointsMap.keys;
                
                fprintf(file,'#sample, frame\n');
                for i = 1 : length(samples)
                    fprintf(file,'%d,%d\n',samples(i),frames(i));
                end
                fclose(file);
            end
        end
    end
    
    methods (Static, Access = private)
    end
end