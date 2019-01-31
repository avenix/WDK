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
        function obj = ManualSegmentation(manualAnnotations)
            obj.createAnnotationsMap(manualAnnotations);
            obj.classesMap = ClassesMap.instance();
            obj.includeEvents = true;
            obj.includeRanges = true;
            obj.name = 'manual';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function segments = compute(obj,data)
            fileName = Helper.removeFileExtension(data.fileName);
            if obj.manualAnnotations.isKey(fileName)
                obj.currentAnnotations = obj.manualAnnotations(fileName);
                segments = obj.segmentFile(data);
            end
        end
        
        %{
        function segments = compute(obj,dataFiles)
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
        %}
        
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
        
        function createAnnotationsMap(obj,annotations)
            obj.manualAnnotations = containers.Map;
            for i = 1 : length(annotations)
                fileName = annotations(i).fileName;
                fileName = Helper.removeAnnotationsExtension(fileName);
                obj.manualAnnotations(fileName) = annotations(i);
            end
        end
        
        function segments = segmentFile(obj,data)
            
            if(obj.includeEvents)
                eventSegments = obj.createManualSegmentsWithEvents(data.data);
            end
            
            if(obj.includeRanges)
                rangeSegments = obj.createSegmentsWithRangeAnnotations(data.data);
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
            validIdxs = (labels ~= obj.classesMap.kSynchronisationClass & labels ~= ClassesMap.kInvalidClass);
            labels = labels(validIdxs);
            eventLocations = [eventAnnotations(validIdxs).sample];
            
            segments = Helper.CreateEventsWithEventLocations(eventLocations);  
            segments = obj.createSegmentsWithEvents(segments,data);
            
            %label segments
            for i = 1 : length(segments)
                segments(i).label = labels(i);
            end
        end
        
        function segments = createSegmentsWithRangeAnnotations(obj,data)
            rangeAnnotations = obj.currentAnnotations.rangeAnnotations;
            nSegments = length(rangeAnnotations);
            segments = repmat(Segment,1,nSegments);
            for i = 1 : length(rangeAnnotations)
                rangeAnnotation = rangeAnnotations(i);
                window = data(rangeAnnotation.startSample:rangeAnnotation.endSample,:);
                segments(i) = Segment(obj.currentAnnotations.fileName,window,rangeAnnotation.label,-1);
                segments(i).startSample = rangeAnnotation.startSample;
                segments(i).endSample = rangeAnnotation.endSample;
            end
        end
    end
end