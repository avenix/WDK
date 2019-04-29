%Singleton class, use instance() to instantiate.
classdef ClassesMap < handle
    
    properties (Access = public, Constant)
        kSynchronisationClass = -2;
        kInvalidClass = -1;
        kNullClass = 0;
        synchronisationStr = 'synchronisation';
    end
    
    properties (Access = public)
        numClasses;
        classesList;
    end
    
    properties (Access = private)
        classesMap;
    end
    
    methods(Static)
        
        function obj = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = ClassesMap();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
    methods (Access = public)
        
        function valid = isValidLabel(obj,labelStr)
            valid = isKey(obj.classesMap,labelStr);
        end
        
        function classStr = stringForClassAtIdx(obj,idx)
            if idx == obj.kNullClass
                classStr = Constants.kNullClassGroupStr;
            elseif idx == obj.kSynchronisationClass
                classStr = obj.synchronisationStr;
            else
                classStr = obj.classesList{idx};
            end
        end
        
        function idx = idxOfClassWithString(obj,classStr)
            if isempty(obj.classesMap)
                idx = [];
            else
                if ~isKey(obj.classesMap,classStr)
                    fprintf('%s: %s\n',Constants.kUndefinedClassError,classStr);
                    idx = [];
                else
                    idx = obj.classesMap(classStr);
                end
            end
        end
    end
    
    methods (Static)
        function b = ShouldIgnoreLabels(labels)
            b = (labels == ClassesMap.kSynchronisationClass | labels == ClassesMap.kInvalidClass);
        end
    end
    
    methods (Access = private)
        
        function obj = ClassesMap()
            
            obj.classesList = obj.loadClassesFile();
            if ~isempty(obj.classesList)
                obj.numClasses = length(obj.classesList);
                obj.createClassesMap(obj.classesList);
            end
            
        end
        
        function classesList = loadClassesFile(~)
            
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
        
        function createClassesMap(obj,classesList)
            if ~isempty(classesList)
                nClasses = length(classesList);
                obj.classesMap = containers.Map(classesList,int8(1:nClasses));
                obj.classesMap(ClassesMap.synchronisationStr) = obj.kSynchronisationClass;
            end
        end
    end
end