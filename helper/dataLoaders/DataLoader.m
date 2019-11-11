% Use it to save and load WDK files (data, annotations, markers,
% synchronization and algorithms)
classdef DataLoader < handle
    
    methods (Static, Access = public)
        
        %% Data files
        
        %loads a binary data file. Full path should be specified
        function dataFile = LoadDataFileBinaryWithFullPath(fullPath)
            dataFile = load(fullPath);
            dataFile = dataFile.dataFile;
        end
        
        %loads a text data file. Full path should be specified
        function dataFile = LoadDataFileTextWithFullPath(fullPath)
            tableImporter = TableImporter();
            data = tableImporter.importTable(fullPath);
            columnNames = data.Properties.VariableNames;
            data = table2array(data);
            dataFile = DataFile(fullPath,data,columnNames);
        end
        
        %loads a data file in text or binary format.
        function dataFile = LoadDataFileBinary(fileName)
            fileName = sprintf('%s/%s',Constants.kDataPath,fileName);
            dataFile = obj.LoadDataFileBinaryWithFullPath(fileName);
        end
        
        %loads a data file in text or binary format. Full path should be specified
        function dataFile = LoadDataFile(fileName)
            fileExtension = Helper.GetFileExtension(fileName);
            fullPath = sprintf('%s/%s',Constants.kDataPath,fileName);
            if strcmp(fileExtension, ".mat")
                dataFile = DataLoader.LoadDataFileBinaryWithFullPath(fullPath);
            elseif strcmp(fileExtension, ".txt")
                dataFile = DataLoader.LoadDataFileTextWithFullPath(fullPath);
                dataFile.fileName = fileName;
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
        
        %convenience method to load the column names of the data file
        %the column names are supposed to be consistent across data files
        function signals = LoadSignalNames()
            dataFiles = Helper.ListDataFiles();
            signals = [];
            if ~isempty(dataFiles)
                fileName = dataFiles{1};
                dataFile = DataLoader.LoadDataFile(fileName);
                signals = dataFile.columnNames;
            end
        end
        
        %% Annotations
        %loads every annotation set in the annotations/ directory and 
        %returns an array of AnnotationSets.
        function annotations = LoadAllAnnotations(defaultLabeling)
            dataFileNames = Helper.ListDataFiles();
            dataFileNames = Helper.RemoveFileExtensionForFiles(dataFileNames);
            annotationFiles = Helper.AddAnnotationsFileExtensionForFiles(dataFileNames);
            
            nAnnotationFiles = length(annotationFiles);
            annotations = repmat(AnnotationSet,1,nAnnotationFiles);
            for i = 1 : length(annotationFiles)
                annotationsFileName = annotationFiles{i};
                annotationSet = DataLoader.LoadAnnotationSet(annotationsFileName,defaultLabeling);
                annotationSet.fileName = annotationsFileName;
                annotations(i) = annotationSet;
            end
        end
        
        %loads an annotation set with a file name
        function annotationSet = LoadAnnotationSet(annotationsFileName,labeling)
            annotationsFileName = sprintf('%s/%s',Constants.kAnnotationsPath,annotationsFileName);
            annotationSet = DataLoader.LoadAnnotationSetFullPath(annotationsFileName,labeling);
        end
        
        %loads an annotation set with the full path to the annotation file
        function annotationSet = LoadAnnotationSetFullPath(annotationsFileName,labeling)
            annotationsParser = AnnotationsParser(labeling);
            annotationSet = annotationsParser.loadAnnotations(annotationsFileName);
        end
        
        %saves an annotation in the current path
        function SaveAnnotations(annotationsSet,annotationsFileName,labeling)
            annotationsParser = AnnotationsParser(labeling);
            annotationsParser.saveAnnotations(annotationsSet,annotationsFileName);
        end

        
        %% Algorithms
        function algorithm = LoadJSONAlgorithmFromFile(fileName)
            fullPath = sprintf('%s/%s',Constants.kARChainsPath,fileName);
            text = fileread(fullPath);
            algorithm = jsondecode(text);
            algorithm = Algorithm.CreateWithStruct(algorithm);
        end
        
        function SaveAlgorithmAsJSON(algorithm, fileName)
            fullPath = sprintf('%s/%s',Constants.kARChainsPath,fileName);
            jsonFile = jsonencode(algorithm);
            fileID = fopen(fullPath,'w');
            fprintf(fileID,'%s\n',jsonFile);
            fclose(fileID);
        end
        
        function algorithm = LoadAlgorithm(fileName)
            fullPath = sprintf('%s/%s',Constants.kARChainsPath,fileName);
            algorithm = load(fullPath);
            algorithm = algorithm.algorithm;
        end
        
        function SaveAlgorithm(algorithm, fileName)
            fullPath = sprintf('%s',fileName);
            save(fullPath,'algorithm');
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
        function synchronizationFiles = LoadAllSynchronizationFiles()
            
            synchronizationFileNames = Helper.ListSynchronizationFileNames();
            nSynchronizationFiles = length(synchronizationFileNames);
            synchronizationFiles = repmat(SynchronizationFile,1,synchronizationFileNames);
            
            for i = 1 : nSynchronizationFiles
                synchronizationFiles(i) = DataLoader.LoadSynchronizationFile(fullFileName);
            end
        end
        
        %loads a video synchronization file with the name of the file
        function synchronizationFile = LoadSynchronizationFile(fileName)
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
                
                if ~synchronizationFile.isValidSynchronizationFile()
                    fprintf('%s - %s\n',Constants.kInvalidSynchronizationFileWarning,fileName);
                end
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
            fileNames = Helper.ListLabelGroupings();
            
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
            name = Helper.RemoveFileExtension(fileName);
            labelMapper = LabelMapper.CreateLabelMapperWithGroups(defaultLabeling,labelGroups,name);
        end
        
        %% Events
        function SaveEvents(events, fileName, labeling)
            if ~isempty(events) && ~isempty(fileName)
                fileID = fopen(fileName,'w');
                
                for i = 1 : length(events)-1
                    event = events(i);
                    DataLoader.PrintEventToFile(fileID,event,labeling);
                    fprintf(fileID, '\n');
                end
                event = events(end);
                DataLoader.PrintEventToFile(fileID,event,labeling);
                fclose(fileID);
            end
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
    
    methods (Static, Access = private)
        function PrintEventToFile(fileID, event,labeling)
            labelStr = labeling.stringForClassAtIdx(event.label);
            fprintf(fileID, '%s, %d',labelStr,event.sample);
        end
    end
end