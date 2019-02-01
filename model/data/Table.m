classdef Table < handle
    
    properties (Access = public)
        table;
    end
    
    properties (Dependent)
        width;
        height;
        features;
        label;
        columnNames;
    end
    
    methods
        function l = get.label(obj)
            l = obj.table.label;
        end
        
        function set.label(obj,l)
            obj.table.label = l;
        end
        
        function h = get.height(obj)
            h = size(obj.table,1);
        end
        
        function w = get.width(obj)
            w = size(obj.table,2);
        end
        
        function fc = get.features(obj)
            fc = obj.table(:,1:end-1);
        end
        
        function cn = get.columnNames(obj)
            cn = obj.table.Properties.VariableNames;
        end
    end
    
    methods (Access = public)
        function obj = Table(table)
            if nargin > 0
                obj.table = table;
            end
        end
        
        function filterTableToLabels(obj,labels)
            includeRowIdxs = ismember(obj.table.label, labels);
            obj.table = obj.table(includeRowIdxs,:);
        end
        
        function filterTableToColumns(obj,columnIdxs)
            obj.table = obj.table(:,columnIdxs);
        end
        
        function dataArray = getDataArray(obj)
            dataArray = table2array(obj.table);
        end
    end
end