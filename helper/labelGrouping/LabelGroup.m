%represents a group of labels
classdef LabelGroup < handle
    properties (Access = public)
        labelName;
        groupsMap;
    end
        
    methods (Access = public)
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