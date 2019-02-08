classdef EventSegmentation < Segmentation

    methods (Access = public)
        
        function obj = EventSegmentation()
            obj.name = 'event-based';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function segments = compute(obj,signal)            
            file = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentDataFile);
            segments = obj.createSegmentsWithEvents(signal,file.data);
        end
        
        function str = toString(obj)
            
            str = sprintf('%s%d%d',obj.name,obj.segmentSizeLeft,obj.segmentSizeRight);
        end
    end
    
end