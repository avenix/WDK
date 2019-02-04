classdef SegmentAxisSelector < Computer
    
    properties (Access = public)
        axes;
    end
    
    methods (Access = public)
        
        function obj = SegmentAxisSelector(axes)
            if nargin > 0
                obj.axes = axes;
            end
            obj.name = 'SegmentAxisSelector';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kNxN);
        end
        
        function newSegment = compute(obj,segment)
            nCols = size(segment.window,2);
            maxExpectedAxes = max(obj.axes);
            if nCols <= maxExpectedAxes
                fprintf('SegmentAxisSelector - %s. input size has: %d columns but should have up to %d columns',Constants.kInvalidInputError,nCols,maxExpectedAxes);
            end
            newSegment = Segment.CreateSegmentWithSegment(segment);
            newSegment.window = segment.window(:,obj.axes);
        end
        
        function str = toString(obj)
            axesStr = Helper.arrayToString(obj.axes);
            axesStr = strrep(axesStr,'\n','');
            str = sprintf('%s%s',obj.name,axesStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('axes',array2JSON(obj.axes));
        end
    end
    
end