classdef RangeSelector < Computer
    
    properties (Access = public)
        rangeStart;
        rangeEnd;
    end
    
    methods (Access = public)
        
        function obj = RangeSelector(rangeStart,rangeEnd)
            if nargin > 0
                obj.rangeStart = rangeStart;
                obj.rangeEnd = rangeEnd;
            end
            obj.name = 'RangeSelector';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function shorterSegment = compute(obj,segment)        
            shorterSegment = Segment.CreateSegmentWithSegment(segment);
            shorterSegment.window = segment.window(obj.rangeStart:obj.rangeEnd,:);
            shorterSegment.startSample = segment.startSample + obj.rangeStart - 1;
            shorterSegment.endSample = segment.endSample - (length(segment.window) - obj.rangeEnd);
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.rangeStart,obj.rangeEnd);
        end
        
        function editableProperties = getEditableProperties(obj)
            rangeStartProperty = Property('rangeStart',obj.rangeStart,[],[],PropertyType.kNumber);
            rangeEndProperty = Property('rangeEnd',obj.rangeEnd,[],[],PropertyType.kNumber);
            
            editableProperties = [rangeStartProperty,rangeEndProperty];
        end
    end
    
end