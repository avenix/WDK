classdef AnnotationSynchronisationFile < handle
    properties
        startFrame;
        endFrame;
    end
    
    methods (Access = public)
        function obj = AnnotationSynchronisationFile(startTs, endTs)
            if nargin > 0
                obj.startFrame = startTs;
                obj.endFrame = endTs;
            end
        end
    end
    
end
