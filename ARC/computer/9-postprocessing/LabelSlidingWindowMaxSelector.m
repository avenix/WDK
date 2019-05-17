%replaces every label at index labelIndex in an array of predicted labels with the most frequent label in the range [labelIndex −windowSize/2,labelIndex +windowSize/2, or with the NULL-class if no label occurs at least minimumCount times in the range

classdef LabelSlidingWindowMaxSelector < Computer
    
    properties (Access = public)
        windowSize = 1;
        minimumCount = 1;
    end
    
    properties (Access = private)
        classCountHash;
    end
    
    methods (Access = public)
        
        function obj = LabelSlidingWindowMaxSelector(windowSize, minimumCount)
            if nargin > 0
                obj.windowSize = windowSize;
                if nargin > 1
                    obj.minimumCount = minimumCount;
                end
            end
            
            obj.name = 'labelSlidingWindowMaxSelector';
            obj.inputPort = ComputerDataType.kLabels;
            obj.outputPort = ComputerDataType.kLabels;
        end
        
        function classificationResults = compute(obj, classificationResults)
            
            nClassificationResults = length(classificationResults);
            for i = 1 : nClassificationResults
                obj.classCountHash = containers.Map('KeyType','double','ValueType','double');
                obj.filterClassificationResults(classificationResults(i));
            end
        end
        
        %counts amount of instances at any time
        function  filterClassificationResults(obj,classificationResult)
            nPredictedClasses = length(classificationResult.predictedClasses);
            filteredPredictedClasses = zeros(nPredictedClasses,1);
                        
            for j = 1 : length(classificationResult.predictedClasses)
                predictedClass = classificationResult.predictedClasses(j);
                
                %add current class
                obj.addClassToClassCountHash(predictedClass);
                
                %remove first class in window
                if j - obj.windowSize >= 1
                    firstClassInWindow = classificationResult.predictedClasses(j - obj.windowSize);
                    obj.classCountHash(firstClassInWindow) = obj.classCountHash(firstClassInWindow) - 1;
                end
                
                %determine maximum
                [class, count] = obj.getMaximumClassAndCount();
                if count >= obj.minimumCount
                    filteredPredictedClasses(j) = class;
                else
                    filteredPredictedClasses(j) = ClassesMap.kNullClass;
                end
            end
            classificationResult.predictedClasses = filteredPredictedClasses;
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.windowSize,obj.minimumCount);
        end
        
        function editableProperties = getEditableProperties(obj)
            windowSizeProperty = Property('windowSize',obj.windowSize,1,512,PropertyType.kNumber);
            minimumCountProperty = Property('minimumCount',obj.minimumCount,1,256,PropertyType.kNumber);
            editableProperties = [windowSizeProperty,minimumCountProperty];
        end
        
        function metrics = computeMetrics(obj,input)
            flops = size(input,1);
            memory = obj.windowSize * Constants.kClassificationResultBytes;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
    methods (Access = private)
        %{
        function fillClassCountBufferForFirstWindow(obj, classes)
            for i = 1 : obj.windowSize
                class = classes(i);
                obj.addClassToClassCountHash(class);
            end
        end
        %}
        
        function addClassToClassCountHash(obj,class)
            if isKey(obj.classCountHash,class)
                obj.classCountHash(class) = obj.classCountHash(class) + 1;
            else
                obj.classCountHash(class) = uint32(1);
            end
        end
        
        function [maxClass, maxCount] = getMaximumClassAndCount(obj)
            keys = obj.classCountHash.keys;
            maxClass = ClassesMap.kNullClass;
            maxCount = 0;
            for i = 1 : length(keys)
                class = keys{i};
                if class ~= ClassesMap.kNullClass
                    count = obj.classCountHash(class);
                    if(count > maxCount)
                        maxCount = count;
                        maxClass = class;
                    end
                end
            end
        end
    end
end
