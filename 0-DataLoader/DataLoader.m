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

        function saveData(~,dataTable,fileName)
            fileName = sprintf('%s.mat',fileName);
            varName = 'dataTable';
            save(fileName,varName);
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
        
        function [data, columnNames] = loadAllDataFiles(~)
            dataFiles = Helper.listDataFiles();
            nDataFiles = length(dataFiles);
            data = cell(1,nDataFiles);
            columnNames = cell(1,nDataFiles);
            
            for i = 1 : length(dataFiles)
                fileName = dataFiles{i};
                [data{i}, columnNames{i}] = DataLoader.loadDataFileWithFullPath(fileName);
            end 
        end
        
        function [data, columnNames] = loadData(obj,fileName)
            fileExtension = Helper.getFileExtension(fileName);
            fileName = sprintf('%s/%s',Constants.dataPath,fileName);
            if strcmp(fileExtension, ".mat")
                [data, columnNames] = obj.loadDataFileWithFullPath(fileName);
            elseif strcmp(fileExtension, ".txt")
                [data, columnNames] = obj.loadTextData(fileName);
            else
                fprintf('DataLoader - unrecognized file extension\n');
                data = [];
                columnNames = [];
            end
        end
                
        function [data, columnNames] = loadTextData(~,fileName)
            
            if exist(fileName, 'file') == 2
                tableImporter = TableImporter();
                data = tableImporter.importTable(fileName);
                columnNames = data.Properties.VariableNames;
                data = table2array(data);
            else
                fprintf('File not found: %s\n',fileName);
                data = [];
            end
        end
                
        %returns an array of AnnotationSet.
        function annotations = loadAllAnnotations(obj)
            annotationFiles = Helper.listAnnotationFiles();
            nAnnotationFiles = length(annotationFiles);
            annotations = repmat(AnnotationSet,1,nAnnotationFiles);
            for i = 1 : length(annotationFiles)
                annotationsFileName = annotationFiles{i};
                annotationSet = obj.loadAnnotations(annotationsFileName);
                annotationSet.file = annotationsFileName;
                annotations(i) = annotationSet;
            end
        end
        
        function annotationSet = loadAnnotations(obj,annotationsFileName)
            if isempty(obj.annotationsLoader)
                obj.annotationsLoader = AnnotationsLoader();
            end
            
            annotationsFileName = sprintf('%s/%s',Constants.annotationsPath,annotationsFileName);
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
                    DataLoader.printEventToFile(fileID,event);
                    fprintf(fileID, '\n');
                end
                event = events(end);
                obj.printEventToFile(fileID,event);
                fclose(fileID);
            end
        end
        
        function markers = loadMarkers(~,markerFileName)
            markersLoader = MarkersLoader();
            
            markerFileName = sprintf('%s/%s',Constants.markersPath,markerFileName);
            markers = markersLoader.loadMarkers(markerFileName);
        end
        
        function labelingStrategies = loadAllLabelingStrategies(obj)
            fileNames = Helper.listLabelingStrategies();
            
            nLabelingStrategies = length(fileNames);
            labelingStrategies = cell(1,nLabelingStrategies+1);
            
            labelingStrategies{1} = ClassLabelingStrategy();
            
            if ~isempty(fileNames)          
                
                obj.lazyInitLabelingStrategiesLoader();
                
                for i = 1 : nLabelingStrategies
                    fileName = fileNames{i};
                    fullFileName = sprintf('%s/%s',Constants.labelingStrategiesPath,fileName);
                    labelingStrategy = obj.labelingStrategiesLoader.loadLabelingStrategy(fullFileName);
                    labelingStrategy.name = Helper.removeFileExtension(fileName);
                    labelingStrategies{i+1} = labelingStrategy;
                end
            end
        end
    end
    
    methods (Access = private)
        function lazyInitLabelingStrategiesLoader(obj)
            if isempty(obj.labelingStrategiesLoader)
                obj.labelingStrategiesLoader = LabelingStrategyLoader();
            end
        end
    end
    
    methods (Static)
        function [data,columnNames] = loadDataFileWithFullPath(fullPath)
            if exist(fullPath, 'file') == 2
                dataTable = load(fullPath);
                dataTable = dataTable.dataTable;
                columnNames = dataTable.Properties.VariableNames;
                data = single(table2array(dataTable));
            else
                fprintf('File not found: %s\n',fullPath);
                data = [];
            end
        end
        
        function printEventToFile(fileID, event)
            fprintf(fileID, '%d',event);
        end
        
        function printRawData(fileHandle, sample)
            for i = 1 : length(sample)-1
                fprintf(fileHandle,'%d\t',sample(i));
            end
            fprintf(fileHandle,'%d',sample(end));
        end
    end
end