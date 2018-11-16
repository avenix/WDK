classdef LowPassFilter < Filter
    properties (Constant,Access = public)
        samplingFrequency = 200;
    end
    properties (Access = public)
        order;
        cutoff;
    end
    
    properties (Access = private)
        lowPassFilter;
    end
    
    methods (Access = public)
        
        function obj = LowPassFilter(order,cutoff)
            obj.order = order;
            obj.cutoff = cutoff;
            myFilterParameters = fdesign.lowpass('N,F3dB', order, cutoff, obj.samplingFrequency);
            obj.lowPassFilter = myFilterParameters.design('butter');
        end
        
        function dataFiltered = filter(obj,data) 
            dataFiltered = filter(obj.lowPassFilter,double(data));
        end
        
        function str = toString(obj)
            str = sprintf('lowpass_%d_%d',obj.order,obj.cutoff);
        end
        
    end
end