%maps labels. Can be used when the annotations contain a greater level of
%detail than needed by the application
classdef LabelMapper < Computer
    
    properties (Access = private)
        hashMap;
    end
    
    properties (Access = public)
        classNames;
    end
    
    methods (Access = public)
        function obj = LabelMapper(hashMap)
            if nargin > 0
                obj.hashMap = hashMap;
            else
                obj.hashMap = containers.Map(uint32(0), uint32(1));
                remove(obj.hashMap,0);
            end
            
            obj.name = 'labelMapper';
            obj.inputPort = ComputerDataType.kLabels;
            obj.outputPort = ComputerDataType.kLabels;
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
        
        function metrics = computeMetrics(obj,classificationResults)
            n = obj.countNumPredictions(classificationResults);
            flops = 4 * n;
            memory = obj.hashMap.Count;
            outputSize = n;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
    methods (Access = private)
        function n = countNumPredictions(~, classificationResults)
            n = 0;
            for i = 1 : length(classificationResults)
                n  = n + length(classificationResults(i).predictedClasses);
            end
        end
    end
end
