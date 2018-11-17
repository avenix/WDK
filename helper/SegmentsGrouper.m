classdef SegmentsGrouper < handle
        
    properties (Access = public)
        classesMap;
    end
    
    methods (Access = public)
        
        %takes input from ManualSegmentsLoader.loadSegments()
        %returns cell array. In each cell i, contains segments of class i
        function groupedSegments = groupSegments(obj,segments,labelingStrategy)
            nClasses = labelingStrategy.numClasses;
            groupedSegments = cell(nClasses,1);
            
            nSegmentsPerClass = obj.countManualSegmentsPerClass(segments,nClasses,labelingStrategy);
            for i = 1 : labelingStrategy.numClasses
                nSegmentsCurrentClass = nSegmentsPerClass(i);
                if nSegmentsCurrentClass > 0
                    groupedSegments{i}(nSegmentsCurrentClass) = Segment();
                end
            end
            
            segmentCounterPerClass = zeros(1,nClasses);
            for currentFile = 1 : length(segments)
                fileSegments = segments{currentFile};
                for i = 1 : length(fileSegments)
                    segment = fileSegments(i);
                    if segment.class ~= obj.classesMap.synchronisationClass
                        label = labelingStrategy.labelForClass(segment.class);
                        newSegment = Segment(segment.file,segment.window,label,segment.eventIdx);
                        counter = segmentCounterPerClass(newSegment.class);
                        counter = counter + 1;
                        segmentCounterPerClass(newSegment.class) = counter;
                        groupedSegments{newSegment.class}(counter) = newSegment;
                    end
                end
            end
        end
        
        %converts the cell array into an array. Returns the 'cutpoints'
        %between classes
        function [fullData, nSamplesPerClass] = convertToFullData(obj,groupedSegments)
            nSamplesPerClass = obj.countSamples(groupedSegments);
            nSamplesTotal = sum(nSamplesPerClass);
            fullData = zeros(nSamplesTotal,19);
            flatSegmentIdx = 1;
            for i = 1 : length(groupedSegments)
                segmentArray = groupedSegments{i};
                for j = 1 : length(segmentArray)
                    segment = segmentArray(j);
                    data = segment.window;
                    segmentSize = size(data,1);
                    fullData(flatSegmentIdx:flatSegmentIdx + segmentSize - 1,:) = data(:,3:end);
                    flatSegmentIdx = flatSegmentIdx + segmentSize;
                end
            end
        end
        
        function nSegmentsPerClass = countSegmentsPerClass(~, groupedSegments)
            nSegmentsPerClass = zeros(1,length(groupedSegments));
            for i = 1 : length(groupedSegments)
                segmentArray = groupedSegments{i};
                nSegmentsPerClass(i) = length(segmentArray);
            end
        end
        
        function nSamplesPerClass = countSamples(~,groupedSegments)
            nSamplesPerClass = zeros(1,length(groupedSegments));
            for i = 1 : length(groupedSegments)
                segmentArray = groupedSegments{i};
                for j = 1 : length(segmentArray)
                    segment = segmentArray(j);
                    nSamplesPerClass(i) = nSamplesPerClass(i) + length(segment.window);
                end
            end
        end
        
    end
    
    methods (Access = private)
        function nSegmentsPerClass = countManualSegmentsPerClass(obj,segments, nClasses, labelingStrategy)
            nSegmentsPerClass = zeros(1,nClasses);
            
            for currentFile = 1 : length(segments)
                fileSegments = segments{currentFile};
                for i = 1 : length(fileSegments)
                    segment = fileSegments(i);
                    if segment.class ~= obj.classesMap.synchronisationClass
                        label = labelingStrategy.labelForClass(segment.class);
                        nSegmentsPerClass(label) = nSegmentsPerClass(label) + 1;
                    end
                end
            end
            
            
        end
    end
    
end