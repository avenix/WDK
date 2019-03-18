classdef Metric < handle
    properties (Access = public)
        flops = 0;
        memory = 0; %in bytes
        outputSize = 0; %in bytes
        f1score = 0;
    end
    
    methods (Access = public)
        function obj = Metric(flops,memory,outputSize,f1score)
            if nargin > 0
                obj.flops = flops;
                obj.memory = memory;
                obj.outputSize = outputSize;
                if nargin > 3
                    obj.f1score = f1score;
                end
            end
        end
        
        function addMetric(obj,metric)
            obj.flops = obj.flops + metric.flops;
            obj.memory = obj.memory + metric.memory;
            obj.outputSize = obj.outputSize + metric.outputSize;
            
        end
    end
end