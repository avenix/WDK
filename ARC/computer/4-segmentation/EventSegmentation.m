classdef EventSegmentation < Computer
    properties (Access = public)
        segmentSizeLeft = 200;
        segmentSizeRight = 30;
    end
     
    methods (Access = public)
        function obj = EventSegmentation()
            obj.name = 'eventSegmentation';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSegment;
        end
        
        function segments = compute(obj,events)            
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            segments = Helper.CreateSegmentsWithEvents(events,file,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function metrics = computeMetrics(obj,input)
            flops = 4 * length(input);
            memory = 8 * length(input);
            outputSize = obj.segmentSizeLeft + obj.segmentSizeRight;
            metrics = Metric(flops,memory,outputSize);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('segmentSizeLeft',obj.segmentSizeLeft,50,300,PropertyType.kNumber);
            property2 = Property('segmentSizeRight',obj.segmentSizeRight,50,300,PropertyType.kNumber);
            editableProperties = [property1,property2];
        end
    end
end
