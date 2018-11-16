%this class is used to define how a class in the peaks file is mapped to a
%class for the classification. We will test different strategies (grouping all the dives,
%grouping all the throws, etc the  depending on the results we get with the
%classification

classdef ClassLabelingStrategy < handle
    
    properties (Access = public)
        numClasses;
        classNames = {};
        nullClass;
    end
    
    properties(Access = private)
        defaultClassesMap;
        classesMap;
    end
    
    methods (Access = public)
        
        function obj = ClassLabelingStrategy(classGroupings)
            obj.defaultClassesMap = ClassesMap();
            if nargin > 0
                obj.generateClassesMap(classGroupings);
            end
        end
    
        function result = isRelevantLabel(obj,classLabel)
            result = (classLabel ~= obj.nullClass);
        end
        
        function label = labelForClass(obj, class)
            if class <= length(obj.classesMap)
                label = obj.classesMap(class);
            else
                label = class;
            end
        end
        
        function labels = labelsForClasses(obj, classes)
            
            labels = zeros(length(classes),1);
            for i = 1 : length(classes)
                class = classes(i);
                labels(i) = obj.labelForClass(class);
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
        function generateClassesMap(obj,classGroupings)
            nGroups = length(classGroupings);
            obj.classNames = cell(1,nGroups);
            
            isClassCovered = obj.computeIsClassCovered(classGroupings);
            classCount = obj.mapUncoveredClasses(isClassCovered);
            
            for i = 1 : nGroups
                classCount = classCount + 1;
                classGrouping = classGroupings(i);
                classesInGroup = keys(classGrouping.groupingsMap);
                for j = 1 : length(classesInGroup)
                    classStr = classesInGroup{j};
                    classIdx = obj.defaultClassesMap.idxOfClassWithString(classStr);
                    obj.classesMap(classIdx) = classCount;
                end
                obj.classNames{classCount} = classGrouping.labelName;
            end
            obj.numClasses = classCount;
            %obj.checkCorrectClassesMap();
        end
        
        function checkCorrectClassesMap(obj)
            for i = 1 : length(obj.classesMap)
                class = obj.classesMap(i);
                if class <= 0
                    fprintf('GroupedClassLabeling - Warning: class %d is not mapped correctly\n',class);
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
        
        function isClassCovered = computeIsClassCovered(obj,classGroupings)
            
            nGroups = length(classGroupings);
            nClasses = obj.defaultClassesMap.numClasses;
            isClassCovered = false(1,nClasses);
            for i = 1 : nGroups
                classGrouping = classGroupings(i);
                classesInGroup = keys(classGrouping.groupingsMap);
                for j = 1 : length(classesInGroup)
                    classStr = classesInGroup{j};
                    classIdx = obj.defaultClassesMap.idxOfClassWithString(classStr);
                    isClassCovered(classIdx) = true;
                end
            end
        end
    end
    
end