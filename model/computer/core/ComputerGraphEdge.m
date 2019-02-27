classdef ComputerGraphEdge < handle
    properties (Access = public)
        source;
        target;
    end
    
    methods (Access = public)
        function obj = ComputerGraphEdge(source,target)
            if nargin > 0
                obj.source = source;
                obj.target = target;
            end
        end
    end
end
