classdef HighPassFilter < Filter
    properties (Constant, Access = public)
        samplingFrequency = 200;
    end
    
    properties (Access = public)
        order;
        cutoff;
    end
    
    properties (Access = private)
        highPassFilterB;
        highPassFilterA;
    end
    
    methods (Access = public)
        function obj = HighPassFilter(order, cutoff)
            obj.order = order;
            obj.cutoff = cutoff;
            [obj.highPassFilterB, obj.highPassFilterA] = butter(order,cutoff/(obj.samplingFrequency/2),'high');
        end
        
        function dataFiltered = filter(obj, data)
            dataFiltered = abs(filtfilt(obj.highPassFilterB, obj.highPassFilterA, double(data)));
        end
        
        function str = toString(obj)
            str = sprintf('highpass_%d_%d',obj.order,obj.cutoff);
        end
    end
end

