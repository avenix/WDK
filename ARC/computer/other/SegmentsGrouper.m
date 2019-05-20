classdef SegmentsGrouper < Computer
        
    properties (Access = public)
        numClasses;
    end
        
    methods (Access = public)
        
        function obj = SegmentsGrouper()            
            obj.name = 'SegmentsGrouper';
            obj.inputPort = ComputerDataType.kSegment;
            obj.outputPort = ComputerDataType.kAny;
        end
        
        function groupedSegments = compute(obj,segments)
            groupedSegments = obj.groupSegments(segments,obj.numClasses);
        end
        
        %returns cell array. In each cell i, contains segments of class i
        function groupedSegments = groupSegments(obj,segments,nClasses)
            
            groupedSegments = cell(nClasses+1,1);
            
            nSegmentsPerClass = obj.countManualSegmentsPerClass(segments,nClasses);
            for i = 1 : nClasses
                nSegmentsCurrentClass = nSegmentsPerClass(i);
                if nSegmentsCurrentClass > 0
                    groupedSegments{i}(nSegmentsCurrentClass) = Segment();
                end
            end
            
            segmentCounterPerClass = zeros(1,nClasses+1);
            for currentFile = 1 : length(segments)
                fileSegments = segments{currentFile};
                for i = 1 : length(fileSegments)
                    segment = fileSegments(i);
                    class = obj.labelForSegment(segment,nClasses);
                    counter = segmentCounterPerClass(class);
                    counter = counter + 1;
                    segmentCounterPerClass(class) = counter;
                    groupedSegments{class}(counter) = segment;
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
                    data = segment.data;
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
                    nSamplesPerClass(i) = nSamplesPerClass(i) + length(segment.data);
                end
            end
        end
        
    end
    
    methods (Access = private)
        function label = labelForSegment(~,segment,nClasses)
            label = segment.label;
            if segment.label == 0
                label = nClasses+1;
            end
        end
        
        function nSegmentsPerClass = countManualSegmentsPerClass(obj,segmentsPerFile, nClasses)
            nSegmentsPerClass = zeros(1,nClasses+1);
            
            for currentFile = 1 : length(segmentsPerFile)
                segments = segmentsPerFile{currentFile};
                for i = 1 : length(segments)
                    class = obj.labelForSegment(segments(i),nClasses);
                    nSegmentsPerClass(class) = nSegmentsPerClass(class) + 1;
                end
            end
            
        end
    end
    
end
