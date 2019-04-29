classdef LabelMapper < Computer
    
    properties (Access = public)
        hashMap;
    end
    
    properties (Access = public)
        classNames;
    end
    
    methods (Access = public)
        function obj = LabelMapper()
            obj.name = 'labelMapper';
            obj.inputPort = ComputerDataType.kLabels;
            obj.outputPort = ComputerDataType.kLabels;
            
            obj.hashMap = containers.Map(uint32(0), uint32(1));
            remove(obj.hashMap,0);
        end
        
        %receives an array of instances of ClassificationResult
        function classificationResults = compute(obj,classificationResults)
            nClassificationResults = length(classificationResults);
            for i = 1 : nClassificationResults
                classificationResult = classificationResults(i);
                classificationResult.truthClasses = obj.mappingForLabels(classificationResult.truthClasses);
                classificationResult.predictedClasses = obj.mappingForLabels(classificationResult.predictedClasses);
                classificationResult.classNames = obj.classNames;
            end
        end
        
        function printLabelsForGrouping(obj,grouping)
            mapKeys = keys(obj.hashMap);
            for i = 1 : length(mapKeys)
                key = mapKeys{i};
                classStr = grouping.classNames{i};
                fprintf('%s - %d %d\n',classStr,key,obj.hashMap(key));
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
                Helper.arrayToString(mapKeys),...
                Helper.arrayToString(mapValues));
            
            str = sprintf('%s_%s',obj.name,hashMapStr);
        end
    end
end
