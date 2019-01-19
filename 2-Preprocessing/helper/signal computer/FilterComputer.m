classdef FilterComputer < Computer
    properties (Access = public)
        filter;
    end
    
    properties (Dependent)
        order;
        cutoff;
    end
    
    methods
        function order = get.order(obj)
            order = obj.filter.order;
        end
        
        function set.order(obj, order)
            obj.filter.order = order;
        end
        
        function cutoff = get.cutoff(obj)
            cutoff = obj.filter.cutoff;
        end
        
        function set.cutoff(obj, cutoff)
            obj.filter.cutoff = cutoff;
        end
    end
    
    methods (Access = public)
        function obj = FilterComputer(filter)
            if nargin > 0
                obj.filter = filter;
            end
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = obj.filter.filter(signal);
        end
        
        function str = toString(obj)
            if isempty(obj.filter)
                str = "empty filter";
            else
                str = sprintf('%s',obj.filter.toString());
            end
        end
        
        function editableProperties = getEditableProperties(~)
            property1 = Property('order',obj.order);
            property2 = Property('cutoff',obj.cutoff);
            editableProperties = [property1,property2];
        end
    end
    
end