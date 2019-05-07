classdef Metric < handle
    properties (Access = public)
        flops = 0;
        memory = 0;
        outputSize = 0;
    end
    
    methods (Access = public)
        function obj = Metric(flops,memory,outputSize)
            if nargin > 0
                obj.flops = flops;
                obj.memory = memory;
                obj.outputSize = outputSize;
            end
        end
    end
end