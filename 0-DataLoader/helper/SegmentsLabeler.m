classdef (Abstract) SegmentsLabeler < handle
    properties (Access = public)
        type;
        labelingStrategy = DefaultLabelingStrategy();
    end
    
    methods (Abstract)
        labelSegments(obj,segments,eventAnnotations)
    end
    
    methods (Access = public)
        
        function str = toString(obj)
            str = obj.segmentationAlgorithm.toString();
        end
        
    end
end