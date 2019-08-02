%maps labels. Can be used when the annotations contain a greater level of
%detail than needed by the application
classdef LabelMapper < Computer

    properties (Access = public)
        sourceLabeling;
        targetLabeling;
    end
    
    properties (Access = private)
        hashMap;
    end
    
    properties (Dependent)
        numSourceClasses;
        numTargetClasses;
        sourceClassNames;
        targetClassNames;
    end
    
    methods
        function n = get.numSourceClasses(obj)
            n = obj.sourceLabeling.numClasses;
        end
        
        function n = get.numTargetClasses(obj)
            n = obj.targetLabeling.numClasses;
        end
        
        function classNames = get.sourceClassNames(obj)
            classNames = obj.sourceLabeling.classNames;
        end
        
        function classNames = get.targetClassNames(obj)
            classNames = obj.targetLabeling.classNames;
        end
    end
    
    methods (Access = public)
        function obj = LabelMapper(sourceLabeling, targetLabeling, hashMap, name)
            if nargin > 0
                obj.hashMap = hashMap;
                obj.sourceLabeling = sourceLabeling;
                obj.targetLabeling = targetLabeling;
                if nargin > 3
                    obj.name = name;
                end
            else
                obj.hashMap = containers.Map(int8(0), int8(1));
                remove(obj.hashMap,0);
            end
            
            if isempty(obj.name)
                obj.name = 'labelMapper';
            end
            
            obj.inputPort = ComputerDataType.kLabels;
            obj.outputPort = ComputerDataType.kLabels;
        end
        
        %receives an array of instances of ClassificationResult or
        %AnnotationSets
        function output = compute(obj,labels)
            if isa(labels(1),'AnnotationSet')
                annotationSet = obj.mapAnnotations(labels);
                output = annotationSet;
            else
                output = obj.mapForClassificationResults(labels);
            end
        end
        
        function classificationResults = mapForClassificationResults(obj,classificationResults)
            nLabels = length(classificationResults);
            for i = 1 : nLabels
                classificationResult = classificationResults(i);
                classificationResult.predictedClasses = obj.mappingForLabels(classificationResult.predictedClasses);
                classificationResult.truthClasses = obj.mappingForLabels(classificationResult.truthClasses);
                classificationResult.classNames = obj.targetClassNames;
            end
        end
        
        function labels = mappingForLabels(obj,labels)
            nLabels = length(labels);
            for i = 1 : nLabels
                labels(i) = obj.mappingForLabel(labels(i));
            end
        end
        
        function mappedLabel = mappingForLabel(obj,label)
            if isKey(obj.hashMap,label)
                mappedLabel = obj.hashMap(label);
            else
                mappedLabel = label;
            end
        end
        
        function addMapping(obj,fromLabel,toLabel)
            obj.hashMap(fromLabel) = toLabel;
        end
        
        function str = toString(obj)
            mapKeys = keys(obj.hashMap);
            mapValues = values(obj.hashMap);
            hashMapStr = sprintf('[%s],[%s]',...
                Helper.arrayToString(cell2mat(mapKeys),' '),...
                Helper.arrayToString(cell2mat(mapValues),' '));
            
            str = sprintf('%s_%s',obj.name,hashMapStr);
        end
    end
    
    methods (Access = private)
        
        function annotationSet = mapAnnotations(obj,annotations)
            annotationSet = AnnotationSet();
            annotationSet.eventAnnotations = obj.mapEventAnnotations(annotations.eventAnnotations);
            annotationSet.rangeAnnotations = obj.mapRangeAnnotations(annotations.rangeAnnotations);
        end
        
        function mappedEventAnnotations = mapEventAnnotations(obj,eventAnnotations)
            nAnnotations = length(eventAnnotations);
            mappedEventAnnotations = repmat(EventAnnotation,1,nAnnotations);
            for i = 1 : nAnnotations
                eventAnnotation = eventAnnotations(i);
                newLabel = obj.mappingForLabel(eventAnnotation.label);
                mappedEventAnnotations(i) = EventAnnotation(eventAnnotation.sample,newLabel);
            end
        end
        
        function mappedRangeAnnotations = mapRangeAnnotations(obj,rangeAnnotations)
            nAnnotations = length(rangeAnnotations);
            mappedRangeAnnotations = repmat(RangeAnnotation,1,nAnnotations);
            for i = 1 : nAnnotations
                rangeAnnotation = rangeAnnotations(i);
                newLabel = obj.mappingForLabel(rangeAnnotation.label);
                mappedRangeAnnotations(i) = RangeAnnotation(rangeAnnotation.startSample,...
                    rangeAnnotation.endSample,newLabel);
            end
        end
    end
    
    methods (Static)
        function labelMapper = CreateLabelMapperWithLabeling(sourceLabeling,name)
            numClasses = sourceLabeling.numClasses;
            hashMap = containers.Map(int8(1:numClasses), int8(1:numClasses));
            labelMapper = LabelMapper(sourceLabeling,sourceLabeling,hashMap,name);
        end
        
        function labelMapper = CreateLabelMapperWithGroups(sourceLabeling,classGroups,name)
            [hashMap, classNames] = LabelMapper.GenerateLabeling(sourceLabeling,classGroups);
            targetLabeling = Labeling(classNames);
            labelMapper = LabelMapper(sourceLabeling,targetLabeling,hashMap,name);
        end
    end
    
    methods (Access = private, Static)
                
        function [labeling, classNames] = GenerateLabeling(sourceLabeling, classGroups)
            nGroups = length(classGroups);
            
            isClassCovered = LabelMapper.computeIsClassCovered(sourceLabeling,classGroups);
            [labeling, classNames, classCount] = LabelMapper.mapUncoveredClasses(sourceLabeling,isClassCovered,nGroups);

            for i = 1 : nGroups
                classCount = classCount + 1;
                classGroup = classGroups(i);
                classesInGroup = keys(classGroup.groupsMap);
                for j = 1 : length(classesInGroup)
                    classStr = classesInGroup{j};
                    classIdx = sourceLabeling.idxOfClassWithString(classStr);
                    labeling(classIdx) = classCount;
                end
                classNames{classCount} = classGroup.labelName;
            end            
        end
        
         function [hashMap, classNames, classCount] = mapUncoveredClasses(sourceLabeling,isClassCovered,nGroups)
            nClasses = sourceLabeling.numClasses;
            
            hashMap = containers.Map(int8(0), int8(1));
            remove(hashMap,0);
            
            classNames = cell(1,nGroups);
            
            classCount = 0;
            for i = 1 : nClasses
                if ~isClassCovered(i)
                    classCount = classCount + 1;
                    hashMap(int8(i)) = int8(classCount);
                    classNames{classCount} = sourceLabeling.stringForClassAtIdx(i);
                end
            end
        end

        function isClassCovered = computeIsClassCovered(sourceLabeling,classGroups)
            nClasses = sourceLabeling.numClasses;
            isClassCovered = false(1,nClasses);
            if ~isempty(classGroups)
                nGroups = length(classGroups);
                for i = 1 : nGroups
                    classGroup = classGroups(i);
                    classesInGroup = keys(classGroup.groupsMap);
                    for j = 1 : length(classesInGroup)
                        classStr = classesInGroup{j};
                        classIdx = sourceLabeling.idxOfClassWithString(classStr);
                        isClassCovered(classIdx) = true;
                    end
                end
            end
        end
        
    end
    
end
