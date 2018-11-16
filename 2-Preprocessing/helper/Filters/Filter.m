classdef(Abstract) Filter < handle
    
    methods (Abstract, Access = public)
        dataFiltered = filter(obj,data);
        str = toString(obj);
    end
end