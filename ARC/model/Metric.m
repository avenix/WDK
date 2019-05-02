classdef Metric < handle
    properties (Access = public)
        flops = 0;
        memory = 0;
        permanentMemory = 0;
        outputSize = 0;
    end
    
    methods (Access = public)
        function obj = Metric(flops,memory,outputSize,permanentMemory)
            if nargin > 0
                obj.flops = flops;
                obj.memory = memory;
                obj.outputSize = outputSize;
                if nargin > 3
                    obj.permanentMemory = permanentMemory;
                end
            end
        end
        
        function addMetrics(obj,metrics)
            if ~isempty(metrics)
                obj.flops = obj.flops + metrics.flops;
                obj.permanentMemory = obj.permanentMemory + metrics.permanentMemory;
                obj.memory = max(obj.memory,obj.permanentMemory + metrics.memory);
                obj.outputSize = metrics.outputSize;
            end
        end
    end
end