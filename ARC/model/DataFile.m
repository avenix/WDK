classdef DataFile < handle
    properties (Access = public)
        fileName;
        columnNames;
        data;
    end
    
    properties (Dependent)
        numRows;
        numColumns;
    end
    
    methods
        function r = get.numRows(obj)
            r = size(obj.data,1);
        end
        
        function c = get.numColumns(obj)
            c = size(obj.data,2);
        end
    end
    
    methods (Access = public)
        function obj = DataFile(fileName,data,columnNames)
            if nargin > 0
                obj.fileName = fileName;
                if nargin > 1
                    obj.data = data;
                    if nargin > 2
                        obj.columnNames = columnNames;
                    end
                end
            end
        end
        
        function table = convertToTable(obj)
            table = array2table(obj.data);
            table.Properties.VariableNames = obj.columnNames;
        end
        
        function file = createFileWithColumnIndices(obj,columnIndices)
            file = DataFile(obj.fileName,obj.data(:,columnIndices),obj.columnNames(columnIndices));
        end
    end
end