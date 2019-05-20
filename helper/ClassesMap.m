%Singleton class, use instance() to instantiate.
classdef ClassesMap < handle
    
    properties (Access = public, Constant)
        kSynchronisationClass = -2;
        kInvalidClass = -1;
        kNullClass = 0;
        synchronisationStr = 'synchronisation';
    end
    
    properties (GetAccess = public)
        numClasses;
        classNames;
    end
    
    properties (Access = private)
        classesMap;
    end
        
    methods (Access = public)
        
        function obj = ClassesMap(classNames)
            obj.classNames = classNames;
            if ~isempty(classNames)
                obj.numClasses = length(classNames);
                obj.createClassesMap(classNames);
            end
        end
        
        function valid = isValidLabel(obj,labelStr)
            valid = isKey(obj.classesMap,labelStr);
        end
        
        function classStr = stringForClassAtIdx(obj,idx)
            if idx == obj.kNullClass
                classStr = Constants.kNullClassGroupStr;
            elseif idx == obj.kSynchronisationClass
                classStr = obj.synchronisationStr;
            else
                classStr = obj.classNames{idx};
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
        
        function createClassesMap(obj,classNames)
            if ~isempty(classNames)
                nClasses = length(classNames);
                obj.classesMap = containers.Map(classNames,int8(1:nClasses));
                obj.classesMap(ClassesMap.synchronisationStr) = obj.kSynchronisationClass;
            end
        end
    end
end