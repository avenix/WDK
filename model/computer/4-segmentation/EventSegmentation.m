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
    end
    
end