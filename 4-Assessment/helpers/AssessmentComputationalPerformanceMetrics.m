classdef AssessmentComputationalPerformanceMetrics < handle
    properties (Access = public)
        numSamples;
        metric;
    end
    
    properties (Dependent)
        flops;
        memory;
        communication;
    end
    
    methods
        function f = get.flops(obj)
            f = obj.metric.flops / obj.numSamples;
        end
        
        function m = get.memory(obj)
            m = obj.metric.memory;
        end
        
        function m = get.communication(obj)
            m = obj.metric.outputSize / obj.numSamples;
        end
    end
    
    methods (Access = public)
        function obj = AssessmentComputationalPerformanceMetrics(metric,numSamples)
            obj.metric = metric;
            obj.numSamples = numSamples;
        end
        
        function addMetric(obj,metric)
            obj.metric.addMetric(metric);
        end
    end
end