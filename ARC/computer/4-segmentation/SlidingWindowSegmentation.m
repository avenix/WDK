classdef SlidingWindowSegmentation < Computer
    properties (Access = public)
        windowSize = 300;
        iterationSize = 150;
    end

    methods (Access = public)
        function obj = SlidingWindowSegmentation(windowSize,iterationSize)
            if nargin > 0
                obj.windowSize = windowSize;
                if nargin > 1
                    obj.iterationSize = iterationSize;
                end
            end
            
            obj.name = 'slidingWindow';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSegment;
        end
        
        function segments = compute(obj,data)
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            nSamples = length(data);
            nSegments = int32 ((nSamples - obj.windowSize + 1) / obj.iterationSize);
            segments = repmat(Segment,1,nSegments);
            segmentsCount = 1;
            for i = 1 : obj.iterationSize : nSamples - obj.windowSize
                endSample = i + obj.windowSize - 1;
                segment = Segment(file.fileName,file.data(i:endSample,:));
                segment.startSample = i;
                segment.endSample = endSample;
                segments(segmentsCount) = segment;
                segmentsCount = segmentsCount + 1;
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.windowSize,obj.iterationSize);
        end
        
        function metrics = computeMetrics(obj,input)
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            nSamples = length(input);
            nSegments = int32 ((nSamples - obj.windowSize + 1) / obj.iterationSize);
            flops = 1787 * length(input);
            memory = 1;
            outputSize = obj.windowSize * file.numColumns * nSegments;
            permanentMemory = obj.windowSize * file.numColumns;
            metrics = Metric(flops,memory,outputSize,permanentMemory);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('windowSize',obj.windowSize,50,1024,PropertyType.kNumber);
            property2 = Property('iterationSize',obj.iterationSize,10,1024,PropertyType.kNumber);
            editableProperties = [property1,property2];
        end
    end
end
