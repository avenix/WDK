classdef EventSegmentation < Algorithm
    properties (Access = public)
        segmentSizeLeft = 200;
        segmentSizeRight = 30;
    end

    methods (Access = public)
        function obj = EventSegmentation(segmentSizeLeft, segmentSizeRight)
            if nargin > 0
                obj.segmentSizeLeft = segmentSizeLeft;
                obj.segmentSizeRight = segmentSizeRight;
            end
            
            obj.name = 'eventSegmentation';
            obj.inputPort = DataType.kEvent;
            obj.outputPort = DataType.kSegment;
        end

        function segments = compute(obj,events)
            file = Algorithm.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            segments = EventSegmentation.CreateSegmentsWithEvents(events,file,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function metrics = computeMetrics(obj,events)
            
            file = Algorithm.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            nSamples = file.numRows;
            nSegments = EventSegmentation.CountNumValidSegments(events,obj.segmentSizeLeft,obj.segmentSizeRight,nSamples);
            
            n = obj.segmentSizeLeft + obj.segmentSizeRight;
            m = file.numColumns;
            
            flops = 11 * nSegments;
            memory = n * m * Constants.kSensorDataBytes;
            outputSize = n * m * nSegments * Constants.kSensorDataBytes;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('segmentSizeLeft',obj.segmentSizeLeft,50,300,PropertyType.kNumber);
            property2 = Property('segmentSizeRight',obj.segmentSizeRight,50,300,PropertyType.kNumber);
            editableProperties = [property1,property2];
        end
    end
    
    methods (Access = public, Static)
        function segments = CreateSegmentsWithEventLocations(eventLocations,...
                dataFile,segmentSizeLeft,segmentSizeRigh)
            
            events = Event.EventsArrayWithEventLocations(eventLocations);
            
            segments = EventSegmentation.CreateSegmentsWithEvents(events,dataFile,...
                segmentSizeLeft,segmentSizeRigh);
        end
        
        function segments = CreateSegmentsWithEvents(events,dataFile,segmentSizeLeft,segmentSizeRight)
            
            nSamples = dataFile.numRows;
            nSegments = EventSegmentation.CountNumValidSegments(events,segmentSizeLeft,segmentSizeRight,nSamples);
            segments = repmat(Segment,1,nSegments);
            segmentsCounter = 0;
            
            for i = 1 : length(events)
                eventLocation = events(i).sample;
                startSample = int32(eventLocation) - int32(segmentSizeLeft);
                endSample = int32(eventLocation) + int32(segmentSizeRight);
                
                if startSample > 0 && endSample <= nSamples
                    segment = Segment(dataFile.fileName,...
                        dataFile.data(startSample : endSample,:),...
                        [], eventLocation);

                    segment.startSample = uint32(startSample);
                    segment.endSample = uint32(endSample);

                    segmentsCounter = segmentsCounter + 1;
                    segments(segmentsCounter) = segment;
                end
            end
        end
    end
    
    methods (Access = private, Static)
        function numValidSegments = CountNumValidSegments(events,segmentSizeLeft,segmentSizeRight,nSamples)
            numValidSegments = 0;
            for i = 1 : length(events)
                eventLocation = events(i).sample;
                startSample = int32(eventLocation) - int32(segmentSizeLeft);
                endSample = int32(eventLocation) + int32(segmentSizeRight);
                if startSample > 0 && endSample <= nSamples
                    numValidSegments = numValidSegments + 1;
                end
            end
        end
    end
end
