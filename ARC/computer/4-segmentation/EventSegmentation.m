classdef EventSegmentation < Computer
    properties (Access = public)
        segmentSizeLeft = 200;
        segmentSizeRight = 30;
    end

    methods (Access = public)
        function obj = EventSegmentation()
            obj.name = 'eventSegmentation';
            obj.inputPort = ComputerDataType.kEvent;
            obj.outputPort = ComputerDataType.kSegment;
        end

        function segments = compute(obj,events)            
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            segments = Helper.CreateSegmentsWithEvents(events,file,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function metrics = computeMetrics(obj,events)
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            n = obj.segmentSizeLeft + obj.segmentSizeRight;
            m = file.numColumns;
            
            flops = 11 * length(events);
            memory = 1;
            outputSize = n * m;
            permanentMemory = n * m;
            metrics = Metric(flops,memory,outputSize,permanentMemory);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('segmentSizeLeft',obj.segmentSizeLeft,50,300,PropertyType.kNumber);
            property2 = Property('segmentSizeRight',obj.segmentSizeRight,50,300,PropertyType.kNumber);
            editableProperties = [property1,property2];
        end
    end
end
