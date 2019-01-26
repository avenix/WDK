classdef DataAnnotationSampleRange < handle
    properties (Access = public)
        sample1;
        sample2;
    end
    
    properties (Access = private)
        nValues = 0;
    end
    
    methods
        function obj = DataAnnotationSampleRange(sample)
            obj.addValue(sample);
        end
        
        function addValue(obj,sample)
            if obj.nValues == 1
                obj.sample2 = sample;
                obj.checkSwapSamples();
                obj.nValues = 2;
            elseif obj.nValues == 0 || obj.nValues == 2
                obj.sample1 = sample;
                obj.sample2 = 0;
                obj.nValues = 1;
            end
        end
        
        function b = isValidRange(obj)
            b = (obj.nValues == 2);
        end
    end
    
    methods (Access = private)
        function checkSwapSamples(obj)
            if obj.sample2 < obj.sample1
                aux = obj.sample1;
                obj.sample1 = obj.sample2;
                obj.sample2 = aux;
            end
        end
    end
end