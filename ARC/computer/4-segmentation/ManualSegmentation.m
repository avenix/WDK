classdef ManualSegmentation < Computer

    properties (Access = public)
        manualAnnotations;
        includeEvents = true;
        includeRanges = true;
        segmentSizeLeft = 200;
        segmentSizeRight = 30;
    end
    
    properties (Access = private)
        currentAnnotations;
    end
    
    methods (Access = public)
        function obj = ManualSegmentation(manualAnnotations)
            obj.createAnnotationsMap(manualAnnotations);
            obj.name = 'manualSegmentation';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSegment;
        end
        
        function segments = compute(obj,data)
            fileName = Helper.removeFileExtension(data.fileName);
            if obj.manualAnnotations.isKey(fileName)
                obj.currentAnnotations = obj.manualAnnotations(fileName);
                segments = obj.segmentFile(data);
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
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('segmentSizeLeft',obj.segmentSizeLeft,50,300,PropertyType.kNumber);
            property2 = Property('segmentSizeRight',obj.segmentSizeRight,50,300,PropertyType.kNumber);
            editableProperties = [property1,property2];
        end
    end
    
    methods (Access = private)
        
        function createAnnotationsMap(obj,annotations)
            obj.manualAnnotations = containers.Map({'a'},{AnnotationSet()});
            remove(obj.manualAnnotations,'a');
            
            for i = 1 : length(annotations)
                fileName = annotations(i).fileName;
                fileName = Helper.removeAnnotationsExtension(fileName);
                obj.manualAnnotations(fileName) = annotations(i);
            end
        end
        
        function segments = segmentFile(obj,dataFile)
            
            if(obj.includeEvents)
                eventSegments = obj.createManualSegmentsWithEvents(dataFile);
            end
            
            if(obj.includeRanges)
                rangeSegments = obj.createSegmentsWithRangeAnnotations(dataFile);
            end
            
            if(obj.includeEvents && obj.includeRanges)
                segments = [eventSegments, rangeSegments];
            elseif(obj.includeEvents && ~obj.includeRanges)
                segments = eventSegments;
            else
                segments = rangeSegments;
            end
        end
        
        function segments = createManualSegmentsWithEvents(obj,dataFile)
            %eliminate invalid
            eventAnnotations = obj.currentAnnotations.eventAnnotations;
            labels = [eventAnnotations.label];
            validIdxs = (labels ~= Labeling.kSynchronisationClass & labels ~= Labeling.kInvalidClass);
            labels = labels(validIdxs);
            eventLocations = [eventAnnotations(validIdxs).sample];
            
            segments = Helper.CreateSegmentsWithEventLocations(eventLocations,dataFile,obj.segmentSizeLeft,obj.segmentSizeRight);  
            
            %label segments
            for i = 1 : length(segments)
                segments(i).label = labels(i);
            end
        end
        
        function segments = createSegmentsWithRangeAnnotations(obj,dataFile)
            rangeAnnotations = obj.currentAnnotations.rangeAnnotations;
            nSegments = length(rangeAnnotations);
            segments = repmat(Segment,1,nSegments);
            for i = 1 : length(rangeAnnotations)
                rangeAnnotation = rangeAnnotations(i);
                window = dataFile.data(rangeAnnotation.startSample:rangeAnnotation.endSample,:);
                segments(i) = Segment(dataFile.fileName,window,rangeAnnotation.label);
                segments(i).startSample = rangeAnnotation.startSample;
                segments(i).endSample = rangeAnnotation.endSample;
            end
        end
    end
end
