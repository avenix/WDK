%Singleton class, use instance() to instantiate. 
classdef ClassesMap < handle
    
    properties (Access = public, Constant)
        kInvalidClass = -1;
        synchronisationStr = 'synchronisation';
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
            if idx == obj.synchronisationClass
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
    
    
    methods (Access = private)
        
      % Guard the constructor against external invocation.  We only want
      % to allow a single instance of this class.  See description in
      % Singleton superclass.
      function obj = ClassesMap()
          
            obj.classesList = obj.loadClassesFile();
            if ~isempty(obj.classesList)
                obj.numClasses = length(obj.classesList);
                obj.createClassesMap(obj.classesList);
                obj.synchronisationClass = obj.numClasses+1;
            end
            
      end
      
        function classesList = loadClassesFile(~)
            
            [fileID,~] = fopen(Constants.classesPath);
            if (fileID < 0)
                fprintf('file not found: %s\n',Constants.classesPath);
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
                obj.classesMap = containers.Map(classesList,uint8(1:nClasses));
                obj.classesMap(ClassesMap.synchronisationStr) = uint8(nClasses+1);
            end
        end
    end
end