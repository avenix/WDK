classdef Property < handle
    properties (Access = public)
        name;
        value = 0;
        minValue = 0;
        maxValue = 1;
        type PropertyType;
    end
    
    methods (Access = public)
        function obj = Property(name,value,minValue,maxValue,type)
            if nargin > 0
                obj.name = name;
                if nargin > 1
                    obj.value = value;
                    if nargin > 2
                        obj.minValue = minValue;
                        obj.maxValue = maxValue;
                        if nargin > 4
                            obj.type = type;
                        end
                    end
                end
            end
            if isempty(obj.type)
                obj.setTypeWithValue();
            end
        end
        
        function setValueWithStr(obj, valueStr)
            if (obj.type == PropertyType.kNumber )
                obj.value = str2double(valueStr);
            else
                obj.value = valueStr;
            end
        end
    end
    
    methods (Access = private)
        function setTypeWithValue(obj)
            if isnumeric(obj.value)
                obj.type = PropertyType.kNumber;
            else
                obj.type = PropertyType.kString;
            end
        end
    end
end