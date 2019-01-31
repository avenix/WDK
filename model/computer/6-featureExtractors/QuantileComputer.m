classdef QuantileComputer < Computer
    properties (Access = public)
        numQuantileParts;
    end
    
    methods (Access = public)
        
        function obj = QuantileComputer(numQuantileParts)
            if nargin > 0
                obj.numQuantileParts = numQuantileParts;
            end
        end
        
        function result = compute(obj,data)
            result = quantile(data,obj.numQuantileParts);
        end
        
        function str = toString(obj)
            str = sprintf('quantile%d',obj.numQuantileParts);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = Property('numQuantileParts',obj.numQuantileParts);
        end
    end
end