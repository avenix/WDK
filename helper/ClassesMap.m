classdef ClassesMap < handle
    
    properties (Access = public, Constant)
        kInvalidClass = -1;
    end
    
    properties (Access = public)
        synchronisationClass;
        numClasses;
        classesList;
        nullClass;
    end
    
    properties (Access = private)
        classesMap;
    end
    
    methods (Access = public)
        function obj = ClassesMap()
            obj.classesList = obj.loadClassesFile();
            obj.numClasses = length(obj.classesList);
            obj.createClassesMap(obj.classesList);
            obj.synchronisationClass = obj.idxOfClassWithString('synchronisation');
        end
        
        function valid = isValidLabel(obj,labelStr)
            valid = isKey(obj.classesMap,labelStr);
        end 
        
        function classStr = stringForClassAtIdx(obj,idx)
            classStr = obj.classesList{idx};
        end
        
        function idx = idxOfClassWithString(obj,classStr)
            idx = obj.classesMap(classStr);
        end
    end
    
    
    methods (Access = private)
        
        function classesList = loadClassesFile(~)
            
            [fileID,~] = fopen(Constants.classesPath);
            if (fileID < 0)
                fprintf('file not found: %s\n',fileName);
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
        
        function createClassesMap(obj,classesList)
            nClasses = length(classesList);
            obj.classesMap = containers.Map(classesList,uint8(1:nClasses));
        end
    end
end