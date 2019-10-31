% Use it to save and load WDK files (data, annotations, markers,
% synchronisation and algorithms)
classdef DataLoader < handle
    
    methods (Static, Access = public)
        
        %% Data files
        
        %loads a binary data file. Full path should be specified
        function dataFile = LoadDataFileBinaryWithFullPath(fullPath)
            dataFile = load(fullPath);
            dataFile = dataFile.dataFile;
        end
        
        %loads a text data file. Full path should be specified
        function dataFile = LoadDataFileTextWithFullPath(fileName)
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
                dataFile = DataLoader.LoadDataFileBinaryWithFullPath(fileName);
            elseif strcmp(fileExtension, ".txt")
                dataFile = DataLoader.LoadDataFileTextWithFullPath(fileName);
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
        
        %% Annotations
        %returns an array of AnnotationSet.
        function annotations = LoadAllAnnotations(defaultLabeling)
            dataFileNames = Helper.listDataFiles();
            dataFileNames = Helper.removeFileExtensionForFiles(dataFileNames);
            annotationFiles = Helper.addAnnotationsFileExtensionForFiles(dataFileNames);
            
            nAnnotationFiles = length(annotationFiles);
            annotations = repmat(AnnotationSet,1,nAnnotationFiles);
            for i = 1 : length(annotationFiles)
                annotationsFileName = annotationFiles{i};
                annotationSet = DataLoader.LoadAnnotationSet(annotationsFileName,defaultLabeling);
                annotationSet.fileName = annotationsFileName;
                annotations(i) = annotationSet;
            end
        end
        
        function annotationSet = LoadAnnotationSet(annotationsFileName,labeling)
            annotationsFileName = sprintf('%s/%s',Constants.kAnnotationsPath,annotationsFileName);
            annotationSet = DataLoader.LoadAnnotationSetFullPath(annotationsFileName,labeling);
        end
        
        function annotationSet = LoadAnnotationSetFullPath(annotationsFileName,labeling)
            annotationsParser = AnnotationsParser(labeling);
            annotationSet = annotationsParser.loadAnnotations(annotationsFileName);
        end
        
        function SaveAnnotations(annotationsSet,annotationsFileName,labeling)
            annotationsParser = AnnotationsParser(labeling);
            annotationsParser.saveAnnotations(annotationsSet,annotationsFileName);
        end

        
        %% Algorithms
        function computer = LoadJSONComputerFromFile(fileName)
            fullPath = sprintf('%s/%s',Constants.kARChainsPath,fileName);
            text = fileread(fullPath);
            computer = jsondecode(text);
            computer = Computer.CreateWithStruct(computer);
        end
        
        function SaveComputerAsJSON(computer, fileName)
            fullPath = sprintf('%s/%s',Constants.kARChainsPath,fileName);
            jsonFile = jsonencode(computer);
            fileID = fopen(fullPath,'w');
            fprintf(fileID,'%s\n',jsonFile);
            fclose(fileID);
        end
        
        function computer = LoadComputer(fileName)
            fullPath = sprintf('%s/%s',Constants.kARChainsPath,fileName);
            computer = load(fullPath);
            computer = computer.computer;
        end
        
        function SaveComputer(computer, fileName)
            fullPath = sprintf('%s',fileName);
            save(fullPath,'computer');
        end
        
        
         %% Classes File
         %loads the labels.txt file in 
        function classesList = LoadLabelsFile()
            [fileID,~] = fopen(Constants.kLabelsPath);
            if (fileID < 0)
                fprintf('file not found: %s\n',Constants.kLabelsPath);
                classesList = [];
            else
                startRow = 1;
                endRow = inf;
                formatSpec = '%s%[^\n\r]';
                classesList = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                classesList = classesList{1};
                fclose(fileID);
            end
        end
        
        %% Markers
        %loads every marker
        function markers = LoadMarkers(markerFileName)
            markersLoader = MarkersLoader();
            
            markerFileName = sprintf('%s/%s',Constants.kMarkersPath,markerFileName);
            markers = markersLoader.loadMarkers(markerFileName);
        end
        
        %% Synchronization files
        %loads every video synchronization file in the videos directory
        function synchronisationFiles = LoadAllSynchronisationFiles()
            
            synchronisationFileNames = Helper.ListSynchronisationFileNames();
            nSynchronisationFiles = length(synchronisationFileNames);
            synchronisationFiles = repmat(SynchronizationFile,1,synchronisationFileNames);
            
            for i = 1 : nSynchronisationFiles
                synchronisationFiles(i) = DataLoader.LoadSynchronisationFile(fullFileName);
            end
        end
        
        %loads a video synchronization file with the name of the file
        function synchronizationFile = LoadSynchronisationFile(fileName)
            synchronizationFile = [];
            fullFileName = sprintf('%s/%s',Constants.kVideosPath,fileName);
            file = fopen(fullFileName);
            
            if file > 0
                synchronizationFile = SynchronizationFile();
                synchronizationFile.fileName = fileName;
                while ~feof(file)
                    line = fgetl(file);
                    if line(1) ~= '#'
                        str = split(line,',');
                        sample = str2double(str{1});
                        frame = str2double(str{2});
                        synchronizationFile.setSynchronizationPoint(sample,frame);
                    end
                end
                fclose(file);
            end
        end
        
        %saves a synchronization file to the current path
        function SaveSynchronizationFile(synchronizationFile,fileName)
            
            file = fopen(fileName,'w');
            if file > 0
                
                samples = synchronizationFile.synchronizationPointsMap.keys;
                frames = synchronizationFile.synchronizationPointsMap.values;
                
                fprintf(file,'#sample, frame\n');
                for i = 1 : length(samples)
                    fprintf(file,'%d, %d\n',samples{i},frames{i});
                end
                fclose(file);
            end
        end
        
        %% Label Mappings
        %loads the labels.txt file and generates a Labeling
        function defaultLabeling = LoadDefaultLabeling()
            classesList = DataLoader.LoadLabelsFile();
            defaultLabeling = Labeling(classesList);
        end
        
        %returns an array of LabelMappings based on the mappings defined in the
        %/labeling directory
        function labelMappers = LoadAllLabelMappings()
            fileNames = Helper.listLabelGroupings();
            
            nLabelGroupings = length(fileNames);
            labelMappers = repmat(LabelMapper,1,nLabelGroupings+1);
            
            %default label mapping
            defaultLabeling = DataLoader.LoadDefaultLabeling();
            labelMappers(1) = LabelMapper.CreateLabelMapperWithLabeling(defaultLabeling,'defaultLabeling');
            
            if ~isempty(fileNames)
                for i = 1 : nLabelGroupings
                    fileName = fileNames{i};
                    labelMappers(i+1) = DataLoader.LoadLabelMapping(defaultLabeling,fileName);
                end
            end
        end
        
        %loads the LabelMapping in the /labeling directory with a specific
        %file name
        function labelMapper = LoadLabelMapping(defaultLabeling,fileName)
            fullFileName = sprintf('%s/%s',Constants.kLabelGroupingsPath,fileName);
            labelGroups = LabelGroupsLoader.LoadLabelGroups(fullFileName);
            name = Helper.removeFileExtension(fileName);
            labelMapper = LabelMapper.CreateLabelMapperWithGroups(defaultLabeling,labelGroups,name);
        end
        
        %% Other
        %checks if a video file exists
        function b = CheckVideoFileExists(fileName)
            fullFileName = sprintf('%s/%s',Constants.kVideosPath,fileName);
            b = DataLoader.CheckFileExists(fullFileName);
        end
        
        %checks if a file exists
        function b = CheckFileExists(fullPath)
            b = exist(fullPath,'file');
        end
    end
end