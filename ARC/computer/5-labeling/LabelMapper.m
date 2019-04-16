classdef LabelMapper < Computer
    
    properties (Access = public)
        labelingStrategy;
    end
    
    methods (Access = public)
        
        function obj = LabelMapper(labelingStrategy)
            if nargin > 0
                obj.labelingStrategy = labelingStrategy;
            end
            
            obj.name = 'labelMapper';
            obj.inputPort = ComputerDataType.kSegment;
            obj.outputPort = ComputerDataType.kSegment;
        end
        
        function segments = compute(obj,segments)

            for i = 1 : length(segments)
                segments(i).label = obj.labelingStrategy.labelForClass(segments(i).label);
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name,obj.labelingStrategy.name);
        end
    end
end
