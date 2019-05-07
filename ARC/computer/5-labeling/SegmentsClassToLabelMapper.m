classdef SegmentsClassToLabelMapper < Computer
    
    properties (Access = public)
        labelGrouping;
    end
    
    methods (Access = public)
        function obj = SegmentsClassToLabelMapper(labelGrouping)
            if nargin > 0
                obj.labelGrouping = labelGrouping;
            end
            
            obj.name = 'segmentsClassToLabelMapper';
            obj.inputPort = ComputerDataType.kSegment;
            obj.outputPort = ComputerDataType.kSegment;
        end
        
        function segments = compute(obj,segments)
            for i = 1 : length(segments)
                segments(i).label = obj.labelGrouping.labelForClass(segments(i).label);
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name,obj.labelGrouping.name);
        end
    end
end
