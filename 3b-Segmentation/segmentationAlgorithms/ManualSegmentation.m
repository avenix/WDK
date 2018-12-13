classdef ManualSegmentation < Segmentation
    
    properties
        manualAnnotations;
    end
    
    properties (Access = private)
        classesMap;
        currentAnnotations;
    end
    
    methods (Access = public)
        function obj = ManualSegmentation()
            obj.classesMap = ClassesMap.instance();
        end
        
        function resetVariables(obj)
            resetVariables@Segmentation(obj);
        end
        
        %returns labeled segments
        function segments = segment(obj,data)
            %eliminate invalid
            eventAnnotations = obj.currentAnnotations.eventAnnotations;
            labels = [eventAnnotations.label];
            validIdxs = (labels ~= obj.classesMap.synchronisationClass & labels ~= ClassesMap.kInvalidClass);
            labels = labels(validIdxs);
            eventLocations = [eventAnnotations(validIdxs).sample];
            
            %create segments
            segments = obj.createSegmentsWithEvents(eventLocations,data);
            
            %label segments
            for i = 1 : length(segments)
                segments(i).class = labels(i);
            end
            
            %add range annotations
            rangeAnnotationSegments = obj.createSegmentsWithRangeAnnotations(data);
            
            segments = [segments, rangeAnnotationSegments];
        end
        
        function str = toString(obj)
            str = sprintf('manual%d%d',obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end
    
    methods (Access = protected)
        function segmentsPerFile = createSegmentsPerFile(obj,dataFiles)
            
            nFiles = length(dataFiles);
            segmentsPerFile = cell(1,nFiles);
            
            for i = 1 : nFiles
                dataFile = dataFiles{i};
                obj.currentAnnotations = obj.manualAnnotations(i);
                segmentsPerFile{i} = obj.segment(dataFile);
            end
        end
    end
    
    methods (Access = private)
        function segments = createSegmentsWithRangeAnnotations(obj,data)
            rangeAnnotations = obj.currentAnnotations.rangeAnnotations;
            file = obj.manualAnnotations.file;
            nSegments = length(rangeAnnotations);
            segments = repmat(Segment,1,nSegments);
            for i = 1 : length(rangeAnnotations)
                rangeAnnotation = rangeAnnotations(i);
                window = data(rangeAnnotation.startSample:rangeAnnotation.endSample,:);
                segments(i) = Segment(file,window,rangeAnnotation.label,-1);
                segments(i).startSample = rangeAnnotation.startSample;
                segments(i).endSample = rangeAnnotation.endSample;
            end
        end
    end
end