
classdef ClassLabelingStrategy < handle
    
    properties (Access = public)
        numClasses;
        classNames = {};
        name;
    end
    
    properties(Access = private)
        defaultClassesMap;
        classesMap;
    end
    
    methods (Access = public)
        
        function obj = ClassLabelingStrategy(classGroups)
            obj.defaultClassesMap = ClassesMap.instance();
            if nargin == 0 
                classGroups = [];
                obj.name = 'default (no grouping)';
            end
            obj.generateClassesMap(classGroups);
        end

        function label = labelForClass(obj, class)
            if (class > 0 && class <= length(obj.classesMap))
                label = obj.classesMap(class);
            else
                label = class;
            end
        end

        function labels = labelsForClasses(obj, classes)
            nClasses = length(classes);
            labels = zeros(nClasses,1);
            for i = 1 : nClasses
                labels(i) = obj.labelForClass(classes(i));
            end
        end
        
        function result = equals(obj, labelingStrategy)
            result = strcmp(class(obj),class(labelingStrategy));
        end
        
        function labelsStr = labelsToString(obj,labels)
            
            labelsStr = obj.classNames(labels);
        end
    end
    
    methods (Access = private)
        function generateClassesMap(obj,classGroups)
            nGroups = length(classGroups);
            obj.classNames = cell(1,nGroups);
            
            isClassCovered = obj.computeIsClassCovered(classGroups);
            classCount = obj.mapUncoveredClasses(isClassCovered);
            
            for i = 1 : nGroups
                classCount = classCount + 1;
                classGroup = classGroups(i);
                classesInGroup = keys(classGroup.groupsMap);
                for j = 1 : length(classesInGroup)
                    classStr = classesInGroup{j};
                    classIdx = obj.defaultClassesMap.idxOfClassWithString(classStr);
                    obj.classesMap(classIdx) = classCount;
                end
                obj.classNames{classCount} = classGroup.labelName;
            end
            obj.numClasses = classCount;
            
            obj.checkCorrectClassesMap();
        end

        function checkCorrectClassesMap(obj)
            for i = 1 : length(obj.classesMap)
                class = obj.classesMap(i);
                if class <= 0
                    fprintf('%s: %d\n',Constants.kIncorretlyMappedClassWarning,class);
                end
            end
        end

        function classCount = mapUncoveredClasses(obj,isClassCovered)
            nClasses = obj.defaultClassesMap.numClasses;
            obj.classesMap = uint8(zeros(1,nClasses));
            classCount = 0;
            for i = 1 : nClasses
                if ~isClassCovered(i)
                    classCount = classCount + 1;
                    obj.classesMap(i) = classCount;
                    obj.classNames{classCount} = obj.defaultClassesMap.stringForClassAtIdx(i);
                end
            end
        end

        function isClassCovered = computeIsClassCovered(obj,classGroups)
            
            nClasses = obj.defaultClassesMap.numClasses;
            isClassCovered = false(1,nClasses);
            if ~isempty(classGroups)
                nGroups = length(classGroups);
                for i = 1 : nGroups
                    classGroup = classGroups(i);
                    classesInGroup = keys(classGroup.groupsMap);
                    for j = 1 : length(classesInGroup)
                        classStr = classesInGroup{j};
                        classIdx = obj.defaultClassesMap.idxOfClassWithString(classStr);
                        isClassCovered(classIdx) = true;
                    end
                end
            end
        end
    end
    
end