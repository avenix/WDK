classdef LowPassFilter < Filter
    
    methods (Access = public)
        
        function obj = LowPassFilter(order,cutoff)
            if nargin > 0
                obj.order = order;
                obj.cutoff = cutoff;
            end
            obj.name = 'lowPass';
        end
        
        function dataFiltered = compute(obj,data)
            myFilterParameters = fdesign.lowpass('N,F3dB', obj.order, obj.cutoff, obj.samplingFrequency);
            f = myFilterParameters.design('butter');
            dataFiltered = filter(f,double(data));
        end
        
    end
end