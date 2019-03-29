classdef OverlappingWindowSegmentation < Computer
    properties (Access = public)
        windowSize = 300;
        iterationSize = 150;
    end
     
    methods (Access = public)
        function obj = OverlappingWindowSegmentation()
            obj.name = 'overlappingWindow';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function segments = compute(obj,data)
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            nSamples = length(data);
            nSegments = int32 (nSamples / obj.iterationSize);
            segments = repmat(Segment,1,nSegments);
            for i = 1 : obj.iterationSize : nSamples - obj.windowSize
                segments(i) = Segment(file.fileName,file.data(i:i+obj.windowSize,:));
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.windowSize,obj.iterationSize);
        end
        
        function metrics = computeMetrics(obj,input)
            flops = 2 * length(input);
            memory = 8 * length(input);
            outputSize = obj.windowSize;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('windowSize',obj.windowSize,50,300,PropertyType.kNumber);
            property2 = Property('iterationSize',obj.iterationSize,50,300,PropertyType.kNumber);
            editableProperties = [property1,property2];
        end
    end
end