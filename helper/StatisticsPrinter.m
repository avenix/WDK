classdef StatisticsPrinter < handle
    methods (Access = public)
        
        function obj = StatisticsPrinter()
        end
        
        function printTableStatistics(obj,featuresTable, labelingStrategy, shouldSort)
            
            obj.printLabelStatistics(featuresTable.label,labelingStrategy,shouldSort);
        end
        
        function printLabelStatistics(obj,labels,labelingStrategy,shouldSort)
            numOccurences = obj.computeNumOccurences(labels,labelingStrategy.numClasses);
            total = sum(numOccurences);
            
            totalRelevant = obj.countRelevantInstances(numOccurences,labelingStrategy);
            totalIrrelevant = total - totalRelevant;
            
            if shouldSort == 1
                [sortedOccurrences, sortedOccurrenceIdx] = sort(numOccurences,'descend');
            else
                sortedOccurrences = numOccurences;
                sortedOccurrenceIdx = 1 : length(numOccurences);
            end
            
            obj.printResults(sortedOccurrences,sortedOccurrenceIdx,total,totalRelevant,totalIrrelevant,labelingStrategy);
        end
        
        function printSegmentStatistics(obj, nSegmentsPerClass, labelingStrategy)
            total = sum(nSegmentsPerClass);
            totalRelevant = 0;
            for i = 1 : length(nSegmentsPerClass)
                if labelingStrategy.isRelevantClass(i)
                    totalRelevant = totalRelevant + nSegmentsPerClass(i);
                end
            end
            totalIrrelevant = total - totalRelevant;
            obj.printResults(nSegmentsPerClass,1:length(nSegmentsPerClass),total,totalRelevant,totalIrrelevant,labelingStrategy);
        end
        
    end
    
    methods (Access = private)
        function printResults(~, sortedOccurrences, sortedOccurenceIdx, total, totalRelevant,totalIrrelevant,labelingStrategy)
            classNames = labelingStrategy.classNames;
            fprintf('Exercise\t #\n');
            for i = 1 : length(sortedOccurrences)
                numInstances = sortedOccurrences(i);
                classIdx = sortedOccurenceIdx(i);
                classNameCell = classNames(classIdx);
                className = classNameCell{1};
                fprintf('%s\t %d\n',className,numInstances);
            end
            fprintf('\n');
            fprintf('total: %d\n',total);
            fprintf('total relevant: %d\n',totalRelevant);
            fprintf('total irrelevant: %d\n',totalIrrelevant);
        end
        
        function numOccurences = computeNumOccurences(~, labels, numClasses)
            numOccurences = zeros(1,numClasses);
            
            for class = 1: numClasses
                numOccurences(class) = sum(labels == class);
            end
        end
        
        function nRelevantInstances = countRelevantInstances(~,numOccurrences, labelingStrategy)
            nRelevantInstances = 0;
            for i = 1 : length(numOccurrences)
                if labelingStrategy.isRelevantLabel(i)
                    nRelevantInstances = nRelevantInstances + numOccurrences(i);
                end
            end
        end
    end
end