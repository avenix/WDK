classdef HighPassFilter < Filter
    
    properties (Access = private)
        highPassFilterB;
        highPassFilterA;
    end
    
    methods (Access = public)
        function obj = HighPassFilter(order, cutoff)
            if nargin > 0
                obj.order = order;
                obj.cutoff = cutoff;
            end
            obj.name = 'highPass';
        end
        
        function dataFiltered = compute(obj, data)
            [b, a] = butter(order,cutoff/(obj.samplingFrequency/2),'high');
            dataFiltered = abs(filtfilt(b, a, double(data)));
        end
    end
end

