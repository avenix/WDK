classdef ClassGroup < handle
    properties
        labelName;
        groupsMap;
    end
        
    methods
        function obj = ClassGroup(labelName)
            if nargin > 0
                obj.labelName = labelName;
            end
            obj.groupsMap = containers.Map();
        end
        
        function [] = addGroupedClass(obj, className)
            obj.groupsMap(className) = 1;
        end
        
        function result = containsString(obj,className)
            result = isKey(obj.groupsMap,className);
        end
    end
end