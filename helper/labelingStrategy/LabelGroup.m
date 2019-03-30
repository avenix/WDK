classdef LabelGroup < handle
    properties
        labelName;
        groupsMap;
    end
        
    methods
        function obj = LabelGroup(labelName)
            if nargin > 0
                obj.labelName = labelName;
            end
            obj.groupsMap = containers.Map();
        end
        
        function [] = addGroupedLabel(obj, label)
            obj.groupsMap(label) = 1;
        end
        
        function b = containsString(obj,label)
            b = isKey(obj.groupsMap,label);
        end
    end
end