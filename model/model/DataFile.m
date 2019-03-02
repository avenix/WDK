classdef DataFile < handle
    properties (Access = public)
        fileName;
        columnNames;
        data;
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
    end
end