classdef Metric < handle
    properties (Access = public)
        flops = 0;
        memory = 0; %in bytes
        outputSize = 0; %in bytes
    end
    
    methods (Access = public)
        function obj = Metric(flops,memory,outputSize)
            if nargin > 0
                obj.flops = flops;
                obj.memory = memory;
                obj.outputSize = outputSize;
            end
        end
        
        function addMetric(obj,metric)
            if ~isempty(metric)
                obj.flops = obj.flops + metric.flops;
                obj.memory = obj.memory + metric.memory;
                obj.outputSize = obj.outputSize + metric.outputSize;
            end
        end
    end
end