%# Use it to save and load data for a file. 
classdef DataLoader < handle
    
    properties (Access = private)
        annotationsLoader;
        classesMap;
        labelingStrategiesLoader;
    end

    methods (Access = public)
        
        function obj = DataLoader()
            obj.classesMap = ClassesMap.instance();
        end

        %% Data Files        
        function data = loadAllDataFiles(obj)
            fileNames = Helper.listDataFiles();
            data = obj.loadDataFiles(fileNames);
        end
        
        function dataFile = loadDataFileWithFullPath(~,fullPath)
            dataFile = load(fullPath);
            dataFile = dataFile.dataFile;
        end
        
        function dataFiles = loadDataFiles(obj,fileNames)
            nDataFiles = length(fileNames);
            dataFiles = repmat(DataFile,1,nDataFiles);
            
            for i = 1 : length(fileNames)
                fileName = fileNames{i};
                dataFiles(i) = obj.loadDataFile(fileName);
            end 
        end
        
        function dataFile = loadDataFile(obj,fileName)
            fileName = sprintf('%s/%s',Constants.kDataPath,fileName);
            dataFile = obj.loadDataFileWithFullPath(fileName);
        end
        
        function [data, columnNames] = loadTextData(~,fileName)
            tableImporter = TableImporter();
            data = tableImporter.importTable(fileName);
            columnNames = data.Properties.VariableNames;
            data = table2array(data);
        end
                
        function dataFile = loadData(obj,fileName)
            fileExtension = Helper.getFileExtension(fileName);
            fileName = sprintf('%s/%s',Constants.kDataPath,fileName);
            if strcmp(fileExtension, ".mat")
                dataFile = obj.loadDataFileWithFullPath(fileName);
            elseif strcmp(fileExtension, ".txt")
                dataFile = obj.loadTextData(fileName);
            else
                dataFile = [];
            end
        end
        
        function saveDataFile(~,dataFile)
            save(dataFile.fileName,'dataFile');
        end
        
        function data = saveTextData(~,data,varNames,fileName)
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
        function annotations = loadAllAnnotations(obj)
            annotationFiles = Helper.listAnnotationFiles();
            nAnnotationFiles = length(annotationFiles);
            annotations = repmat(AnnotationSet,1,nAnnotationFiles);
            for i = 1 : length(annotationFiles)
                annotationsFileName = annotationFiles{i};
                annotationSet = obj.loadAnnotations(annotationsFileName);
                annotationSet.fileName = annotationsFileName;
                annotations(i) = annotationSet;
            end
        end
        
        function annotationSet = loadAnnotations(obj,annotationsFileName)
            if isempty(obj.annotationsLoader)
                obj.annotationsLoader = AnnotationsLoader();
            end
            
            annotationsFileName = sprintf('%s/%s',Constants.kAnnotationsPath,annotationsFileName);
            annotationSet = obj.annotationsLoader.loadAnnotations(annotationsFileName);
        end
        
        function saveAnnotations(obj,annotationsSet,annotationsFileName)
            obj.annotationsLoader.saveAnnotations(annotationsSet,annotationsFileName);
        end
        
        function saveEvents(obj,events, fileName)
            if ~isempty(events) && ~isempty(fileName)
                fileID = fopen(fileName,'w');
                
                for i = 1 : length(events)-1
                    event = events(i);
                    obj.printEventToFile(fileID,event);
                    fprintf(fileID, '\n');
                end
                event = events(end);
                obj.printEventToFile(fileID,event);
                fclose(fileID);
            end
        end
        
        %% Markers
        function markers = loadMarkers(~,markerFileName)
            markersLoader = AnnotationMarkersLoader();
            
            markerFileName = sprintf('%s/%s',Constants.kMarkersPath,markerFileName);
            markers = markersLoader.loadMarkers(markerFileName);
        end
        
        %% Labeling Strategies
        function labelingStrategies = loadAllLabelingStrategies(obj)
            fileNames = Helper.listLabelingStrategies();
            
            nLabelingStrategies = length(fileNames);
            labelingStrategies = repmat(ClassLabelingStrategy, 1,nLabelingStrategies+1);
            
            labelingStrategies(1) = ClassLabelingStrategy();
            
            if ~isempty(fileNames)          
                
                obj.lazyInitLabelingStrategiesLoader();
                
                for i = 1 : nLabelingStrategies
                    fileName = fileNames{i};
                    labelingStrategies(i+1) = obj.loadLabelingStrategy(fileName);
                end
            end
        end
        
        function labelingStrategy = loadLabelingStrategy(obj,fileName)
            fullFileName = sprintf('%s/%s',Constants.kLabelingStrategiesPath,fileName);
            labelingStrategy = obj.labelingStrategiesLoader.loadLabelingStrategy(fullFileName);
            labelingStrategy.name = Helper.removeFileExtension(fileName);
        end

        %% Synchronisation Files
        function synchronisationFiles = loadAllSynchronisationFiles(obj)
            
            synchronisationFileNames = Helper.ListSynchronisationFileNames();
            nSynchronisationFiles = length(synchronisationFileNames);
            synchronisationFiles = repmat(AnnotationSynchronisationFile,1,synchronisationFileNames);
            
            for i = 1 : nSynchronisationFiles
                synchronisationFiles(i) = obj.loadSynchronisationFile(fullFileName);
            end
        end
        
        function synchronisationFile = loadSynchronisationFile(obj,fileName)
            synchronisationFile = [];
            fullFileName = sprintf('%s/%s',Constants.kVideosPath,fileName);
            file = fopen(fullFileName);
            
            if file > 0
                sample1 = obj.readFileLineSecondColumn(file);
                sample2 = obj.readFileLineSecondColumn(file);
                frame1 = obj.readFileLineSecondColumn(file);
                frame2 = obj.readFileLineSecondColumn(file);
                synchronisationFile = AnnotationSynchronisationFile(sample1,sample2,frame1,frame2);
                fclose(file);
            end
        end
    end
    
    methods (Access = private)
        function value = readFileLineSecondColumn(~,file)
            line = fgets(file);
            str = split(line);
            value = str2double(str{2});
        end
        
        function lazyInitLabelingStrategiesLoader(obj)
            if isempty(obj.labelingStrategiesLoader)
                obj.labelingStrategiesLoader = LabelingStrategyLoader();
            end
        end
        
        function printEventToFile(obj,fileID, event)
            labelStr = obj.classesMap.stringForClassAtIdx(event.label);
            fprintf(fileID, '%s, %d',labelStr,event.sample);
        end
    end
    
    methods (Static)
        
        function b = CheckVideoFileExists(fileName)
            fullFileName = sprintf('%s/%s',Constants.kVideosPath,fileName);
            b = DataLoader.CheckFileExists(fullFileName);
        end
        
        function b = CheckFileExists(fullPath)
            b = exist(fullPath,'file');
        end
        
        function computer = LoadJSONComputerFromFile(fileName)
            fullPath = sprintf('%s/%s',Constants.kFeaturesPath,fileName);
            text = fileread(fullPath);
            computer = jsondecode(text);
            computer = Computer.CreateWithStruct(computer);
        end
        
        function SaveComputerAsJSON(computer, fileName)
            fullPath = sprintf('%s/%s',Constants.kFeaturesPath,fileName);
            jsonFile = jsonencode(computer);
            fileID = fopen(fullPath,'w');
            fprintf(fileID,'%s\n',jsonFile);
            fclose(fileID);
        end
        
        function computer = LoadComputer(fileName)
            fullPath = sprintf('%s/%s',Constants.kFeaturesPath,fileName);
            computer = load(fullPath);
            computer = computer.computer;
        end
        
        function SaveComputer(computer, fileName)
            fullPath = sprintf('%s',fileName);
            save(fullPath,'computer');
        end
        
        function printRawData(fileHandle, sample)
            for i = 1 : length(sample)-1
                fprintf(fileHandle,'%d\t',sample(i));
            end
            fprintf(fileHandle,'%d',sample(end));
        end
    end
end