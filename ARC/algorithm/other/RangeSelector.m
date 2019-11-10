classdef RangeSelector < Algorithm
    
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
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kSignal;
        end
        
        function shorterSegment = compute(obj,segment)
            endIdx = obj.endIndexForSegment(segment);
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
        
        function metrics = computeMetrics(obj,segment)
            n = size(segment,1);
            flops = 2 * n;
            endIdx = obj.endIndexForSegment(segment);
            memory = 1;
            outputSize = endIdx - obj.rangeStart + 1;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
    methods (Access = private)
        function endIdx = endIndexForSegment(obj,segment)
            endIdx = obj.rangeEnd;
            if isempty(endIdx)
                endIdx = size(segment,1);
            end
        end
    end
    
end
