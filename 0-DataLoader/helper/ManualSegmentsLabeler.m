classdef ManualSegmentsLabeler < SegmentsLoader
    
    %use superclass: loadSegments(obj, fileIdxs) or loadAllSegments(obj)
    methods (Access = public)
        function obj = ManualSegmentsLabeler()
            obj.type = 'manual';
        end
        
        function labelSegments(~,segments,eventAnnotations)
            if length(segments) ~= length(eventAnnotations)
                fprintf('Error. ManualSegmentsLoader - input lengths dont match.\n');
            end
            segments.labels = [eventAnnotations.label];
        end
        
        %{
        %this is public due to matlab limitation of abstract classes
        function segments = createSegmentsWithFile(obj,fileName, fileIdx)
            dataLoader = DataLoader();
            
            data = dataLoader.loadData(fileName);
            annotationsFileName = Helper.removeDataFileExtension(fileName);
            annotationsFileName = Helper.addPeaksFileExtension(annotationsFileName);
            [eventAnnotations, ~] = dataLoader.loadAnnotations(annotationsFileName);
            
            if ~isempty(data) && ~isempty(eventAnnotations)

                peakLocations = [eventAnnotations.sample];
                classes = [eventAnnotations.label];
                obj.segmentationAlgorithm.manualPeakLocations = peakLocations;
                [segmentStartings, segmentEndings] = obj.segmentationAlgorithm.segment(data);
                
                isValidSegment = (classes ~= obj.classesMap.synchronisationClass);
                
                nSegments = sum(isValidSegment);
                segments(1,nSegments) = Segment();
                
                segmentCounter = 1;
                for i = 1 : length(peakLocations)
                    if isValidSegment(i)
                        class = classes(i);
                        peakLocation = peakLocations(i);
                        starting = segmentStartings(i);
                        ending = segmentEndings(i);
                        window = data(starting:ending,:);
                        segments(segmentCounter) = Segment(fileIdx,window,class,peakLocation);
                        segmentCounter = segmentCounter + 1;
                    end
                end
                
            end
        end
        
        %this is public due to matlab limitation of abstract classes
        function nullSegmentData = extractNullMotion(obj,segmentData)
            
            nullSegmentData = zeros(size(segmentData,1),4);
            
            currentDataIdx = 1;
            nullMotionCount = 1;
            for i = 1 : length(segmentData)
                segmentStart = segmentData(i,1);
                segmentEnd = segmentData(i,2);
                if currentDataIdx < segmentStart
                    nullSegmentData(nullMotionCount,:) = [currentDataIdx,segmentStart-1,obj.labelingStrategy.nullClass,0];
                    nullMotionCount = nullMotionCount + 1;
                end
                currentDataIdx = segmentEnd;
            end
            nullSegmentData = nullSegmentData(1:nullMotionCount-1,:);
        end
%}
        
    end
    
end

