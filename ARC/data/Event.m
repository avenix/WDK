classdef Event < Data 
    properties (Access = public)
        sample;
        label;
    end
    
    methods (Access = public)
        function obj = Event(sample,label)
            if nargin == 2
                obj.sample = sample;
                obj.label = label;
            end
            obj.type = DataType.kEvent;
        end
    end
end