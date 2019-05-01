classdef TableImporter < handle
    methods (Access = public)
        function obj = TableImporter()
        end
        
        function table = importTable(~, fileName)
            table = readtable(fileName);
        end
    end
end