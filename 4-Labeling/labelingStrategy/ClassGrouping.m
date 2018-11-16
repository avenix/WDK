classdef ClassGrouping < handle
    properties
        labelName;
        groupingsMap;
    end
        
    methods
        function obj = ClassGrouping(labelName)
            if nargin > 1
                obj.labelName = labelName;
            end
            obj.groupingsMap = containers.Map();
        end
        
        function [] = addGroupedClass(obj, className)
            obj.groupingsMap(className) = 1;
        end
        
        function result = containsString(obj,className)
            result = isKey(obj.groupingsMap,className);
        end
    end
end