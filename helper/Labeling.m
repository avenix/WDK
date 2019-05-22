%Singleton class, use instance() to instantiate.
classdef Labeling < handle
    
    properties (Access = public, Constant)
        kSynchronisationClass = -2;
        kInvalidClass = -1;
        kNullClass = 0;
        kNullClassStr = 'NULL';
        kSynchronisationStr = 'synchronisation';
    end
    
    properties (GetAccess = public)
        numClasses;
        classNames;
    end
    
    properties (Access = private)
        classesMap;
    end
    
    methods (Access = public)
        function obj = Labeling(classNames)
            obj.classNames = classNames;
            if ~isempty(classNames)
                obj.numClasses = length(classNames);
                obj.createLabeling(classNames);
            end
        end
        
        function valid = isValidLabel(obj,labelStr)
            valid = isKey(obj.classesMap,labelStr);
        end
        
        function classStr = stringForClassAtIdx(obj,idx)
            if idx == Labeling.kNullClass
                classStr = Labeling.kNullClassStr;
            elseif idx == Labeling.kSynchronisationClass
                classStr = Labeling.kSynchronisationStr;
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
            b = (labels == Labeling.kSynchronisationClass | labels == Labeling.kInvalidClass);
        end
    end
    
    methods (Access = private)
        function createLabeling(obj,classNames)
            if ~isempty(classNames)
                nClasses = length(classNames);
                obj.classesMap = containers.Map(classNames,int8(1:nClasses));
                obj.classesMap(Labeling.kSynchronisationStr) = Labeling.kSynchronisationClass;
                obj.classesMap(Labeling.kNullClassStr) = Labeling.kNullClass;
            end
        end
    end
end