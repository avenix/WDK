classdef LabelMapper < Computer
    
    properties (Access = private)
        hashMap;
    end
    
    methods (Access = public)
        function obj = LabelMapper()
            obj.name = 'labelMapper';
            obj.inputPort = ComputerDataType.kLabels;
            obj.outputPort = ComputerDataType.kLabels;
            
            obj.hashMap = containers.Map(uint32(0), uint32(1));
            remove(obj.hashMap,0)
        end
        
        %receives an instance of ClassificationResult
        function classificationResults = compute(obj,classificationResults)
            nClassificationResults = length(classificationResults);
            for i = 1 : nClassificationResults
                classificationResults = classificationResults(i);
                classificationResults.truthClasses = obj.mappingForLabels(classificationResults.truthClasses);
                classificationResults.predictedClasses = obj.mappingForLabels(classificationResults.predictedClasses);
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
            valuesStr = sprintf('[%s],[%s]',...
                Helper.arrayToString(mapKeys),...
                Helper.arrayToString(mapValues));
            
            str = sprintf('%s_%s',obj.name,valuesStr);
        end
    end
end
