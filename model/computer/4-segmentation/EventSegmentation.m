classdef EventSegmentation < Segmentation

    methods (Access = public)
        
        function obj = EventSegmentation()
            obj.name = 'eventSegmentation';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function segments = compute(obj,events)            
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            segments = obj.createSegmentsWithEvents(events,file.data);
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
        
        function metrics = computeMetrics(~,input)
            flops = 4 * length(input);
            memory = 8 * length(input);
            outputSize = obj.segmentSizeLeft + obj.segmentSizeRight;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end