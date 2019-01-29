classdef(Abstract) Filter < Computer
    
    properties (Access = public)
        samplingFrequency = 200;
        order = 1;
        cutoff = 20;
    end
        
    methods (Access = public)
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.order,obj.cutoff);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('order',obj.order,1,4);
            property2 = Property('cutoff',obj.cutoff,1,20);
            editableProperties = [property1,property2];
        end
    end
    
end