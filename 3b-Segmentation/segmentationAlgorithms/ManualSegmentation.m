classdef ManualSegmentation < Segmentation
    
    properties (Access = public)
        manualAnnotations;
        includeEvents;
        includeRanges;
    end
    
    properties (Access = private)
        classesMap;
        currentAnnotations;
    end
    
    methods (Access = public)
        function obj = ManualSegmentation()
            obj.classesMap = ClassesMap.instance();
            obj.includeEvents = true;
            obj.includeRanges = true;
            obj.type = 'manual';
        end
        
        function resetVariables(obj)
            resetVariables@Segmentation(obj);
        end
        
        %returns labeled segments
        function segments = segment(obj,dataFiles)
            
            nFiles = length(dataFiles);
            nAnnotations = length(obj.manualAnnotations);
            if nFiles ~= nAnnotations
                fprintf('%s = ManualSegmentation\n',Constants.kInconsistentAnnotationAndDataFiles);
                segments = [];
            else
                segments = cell(1,nFiles);
                
                for i = 1 : nFiles
                    dataFile = dataFiles{i};
                    obj.currentAnnotations = obj.manualAnnotations(i);
                    segments{i} = obj.segmentFile(dataFile);
                end
            end
        end
        
        function str = toString(obj)
            includeEventsStr = "";
            if(obj.includeEvents)
                includeEventsStr = "E";
            end
            
            includeRangesStr = "";
            if(obj.includeRanges)
                includeRangesStr = "R";
            end
            
            str = sprintf('manual%d%d%s%s',obj.segmentSizeLeft,obj.segmentSizeRight,includeEventsStr,includeRangesStr);
        end
    end
    
    methods (Access = private)
        
        function segments = segmentFile(obj,data)
            
            if(obj.includeEvents)
                eventSegments = obj.createManualSegmentsWithEvents(data);
            end
            
            if(obj.includeRanges)
                rangeSegments = obj.createSegmentsWithRangeAnnotations(data);
            end
            
            if(obj.includeEvents && obj.includeRanges)
                segments = [eventSegments, rangeSegments];
            elseif(obj.includeEvents && ~obj.includeRanges)
                segments = eventSegments;
            else
                segments = rangeSegments;
            end
        end
        
        function segments = createManualSegmentsWithEvents(obj,data)
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
        end
        
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