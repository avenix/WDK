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
            else
                obj.rangeStart = 1;
            end
            obj.name = 'RangeSelector';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function shorterSegment = compute(obj,segment)
            endIdx = obj.rangeEnd;
            if isempty(endIdx)
                endIdx = size(segment,1);
            end
            shorterSegment = segment(obj.rangeStart:endIdx,:);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.rangeStart,obj.rangeEnd);
        end
        
        function editableProperties = getEditableProperties(obj)
            rangeStartProperty = Property('rangeStart',obj.rangeStart,[],[],PropertyType.kNumber);
            rangeEndProperty = Property('rangeEnd',obj.rangeEnd,[],[],PropertyType.kNumber);
            
            editableProperties = [rangeStartProperty,rangeEndProperty];
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            flops = 2 * n;
            memory = obj.rangeEnd - obj.rangeStart + 1;
            outputSize = obj.rangeEnd - obj.rangeStart + 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
end
