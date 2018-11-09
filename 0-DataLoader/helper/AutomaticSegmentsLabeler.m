classdef AutomaticSegmentsLabeler < SegmentsLoader
    properties (Access = private)
        classesMap;
    end
    
    %this is public due to matlab limitation of abstract classes
    methods (Access = public)
        function obj = AutomaticSegmentsLabeler()
            obj.type = 'automatic';
            obj.classesMap = ClassesMap();
        end

        function labelSegments(obj,segments,eventAnnotations)
            
            labeler = PeaksLabeler();
            labeler.labelingStrategy = obj.labelingStrategy;
            labels = labeler.label([segments.peakIdx],eventAnnotations);
            segments.labels = labels;
        end
    
        %{
        function segments = createSegmentsWithFile(obj,fileName, fileIdx)
            
            dataLoader = DataLoader();
            data = dataLoader.loadData(fileName);
            segments = [];
            if ~isempty(data)
                
                peaksFileName = Helper.removeDataFileExtension(fileName);
                peaksFileName = Helper.addPeaksFileExtension(peaksFileName);
                [eventAnnotations, ~] = dataLoader.loadAnnotations(peaksFileName);
                if ~isempty(eventAnnotations)
                                        
                    
                    numSamples = length(data);
                    [segmentStartings, segmentEndings] = obj.segmentationAlgorithm.computeSegmentsBasedOnPeaks(peakLocations,numSamples);
                    
                    segments = obj.createSegmentsFromIndices(segmentStartings,segmentEndings,data,labels,fileIdx);
                end
            end
        end
        %}
    end
    
    %{
    methods (Access = private)
        
        function  classes = labelSegmentsWithPeaks(obj,segments,eventAnnotations)
            
            nSegments = length(segments);
            classes = zeros(1,nSegments);
            
            %labeling
            for i = 1 : nSegments
                segment = segments(i);
                segmentStarting = segment.startSample;
                segmentEnding = segment.endSample;
                segmentLabel = obj.labelingStrategy.nullClass;
                peakIdxs = SegmentsLabeler.findPeaksContainedInSegment(segmentStarting,segmentEnding,eventAnnotations);
                
                if length(peakIdxs) == 1
                    segmentLabel = manualPeakClasses(peakIdxs(1));
                elseif length(peakIdxs) > 1% there are many peaks for this segment
                    foundPeakClasses = manualPeakClasses(peakIdxs);                    
                    uniquePeakClasses = unique(foundPeakClasses);
                    if length(uniquePeakClasses) == 1 %they were the same class
                        segmentLabel = uniquePeakClasses(1);
                    else
                        uniquePeakLabels = obj.labelingStrategy.labelsForClasses(uniquePeakClasses);
                        isRelevantPeakLabel = obj.labelingStrategy.isRelevantLabel(uniquePeakLabels);
                        numRelevantLabels = sum(isRelevantPeakLabel);
                        if numRelevantLabels == 1
                            segmentLabel = uniquePeakClasses(isRelevantPeakLabel);
                        elseif numRelevantLabels == 0
                            segmentLabel = uniquePeakClasses(1);
                        else
                            fprintf('invalid class %d with labels: %s\n',i,mat2str(uniquePeakLabels));
                            segmentLabel = Constants.kInvalidClass;
                        end
                    end
                end
                classes(i) = segmentLabel;
            end
        end
        
        %{
        function segmentLabels = labelJoggingSegments(~,segments,segmentLabels)
            
            %label segments based on jogging intervals
            for currentSegment = 1 : length(segmentStartings)
                
                segment = segments(currentSegment);
                segmentStarting = segment.window(1,1);
                segmentEnding = segment.window(end,1);
                overlappingSegments = SegmentsLabeler.findOverlappingSegmentIndicesWithSegments(segmentStarting,segmentEnding,manualPeakData.joggingStartings,manualPeakData.joggingEndings);
                if length(overlappingSegments) == 1
                    joggingClassidx = overlappingSegments(1);
                    segmentLabels(currentSegment) = manualPeakData.joggingClasses(joggingClassidx);
                elseif length(overlappingSegments) > 1
                    fprintf("found more than one jogging segment for segment %d-%d\n",segmentStarting,segmentEnding);
                end
            end
        end
        %}
        
         function [peaksContained] = findPeaksContainedInSegment(~, segmentStarting, segmentEnding, manualPeakLocations)
            
            peaksContained = [];
            
            for i = 1 : length(manualPeakLocations)
                
                peakLocation = manualPeakLocations(i);
                
                if Helper.isPointContainedInSegment(peakLocation,segmentStarting, segmentEnding)
                    peaksContained = [peaksContained i];
                end
                
                if peakLocation > segmentEnding
                    break;
                end
            end
        end
        
        %{
        function [result] = findOverlappingSegmentIndicesWithSegments(~, segmentStarting,segmentEnding,joggingSegmentStartings,joggingSegmentEndings)
            
            result = [];
            
            for currentSegment = 1 : length(joggingSegmentStartings)
                
                joggingSegmentStarting = joggingSegmentStartings(currentSegment);
                joggingSegmentEnding = joggingSegmentEndings(currentSegment);
                
                if doSegmentsOverlap(segmentStarting, segmentEnding,joggingSegmentStarting, joggingSegmentEnding)
                    result = [result currentSegment];
                    break;
                end
                
                if joggingSegmentStarting > segmentEnding
                    break;
                end
            end
        end
        
        
        function [result] = doSegmentsOverlap(~, start1, end1, start2, end2)
            result = ~(end1 < start2 || start1 > end2);
        end
        %}
        
        
        %{
        function segments = createSegmentsFromIndices(obj,segmentStartings,segmentEndings,data,labels,fileIdx)
            nSegments = length(segmentStartings);
            segments = [];
            
            if nSegments > 0
                segments = repmat(Segment(),1,nSegments);
                
                for i = 1:length(segmentStartings)
                    segmentStarting = segmentStartings(i);
                    segmentEnding = segmentEndings(i);
                    window = data(segmentStarting:segmentEnding,:);
                    peakIdx = segmentStarting + obj.segmentationAlgorithm.segmentSizeLeft;
                    segments(i) = Segment(fileIdx,double(window),labels(i),peakIdx);
                end
                segments = obj.eliminateInvalidSegments(segments);
            end
        end
        
        %eliminates the segments that contain a synchronisation clap or two
        %manual peaks
        function  filteredSegments = eliminateInvalidSegments(obj,segments)
            
            filteredSegments(1,length(segments)) = Segment();
            segmentsCounter = 0;
            
            for i = 1 : length(segments)
                currentSegment = segments(i);
                if currentSegment.class ~= ClassesMap.kInvalidClass && currentSegment.class ~= obj.classesMap.synchronisationClass
                    segmentsCounter = segmentsCounter + 1;
                    filteredSegments(segmentsCounter) = segments(i);
                end
            end
            filteredSegments = filteredSegments(1:segmentsCounter);
        end
        %}
    
    end
    
    %}
end

