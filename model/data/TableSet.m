%contains a set of tales (cell array) and operations to merge them
classdef TableSet < handle
    
    properties (Access = public)
        tables;
    end
    
    methods (Access = public)
        function obj = TableSet(tables)
            obj.tables = tables;
        end
        
        function table = mergedTableForIndices(obj,indices)
            selectedTables = obj.tables(indices);
            table = obj.mergeTables(selectedTables);
        end
        
        function table = mergedTables(obj)
            table = obj.mergeTables(obj.tables);
        end
        
        function nTables = NTables(obj)
            nTables = length(obj.tables);
        end
        
        function nInstances = NInstances(obj)
            nInstances = 0;
            for i = 1 : length(obj.tables) 
                nInstances = nInstances + obj.tables(i).height;
            end
        end
        
        function labels = getAllLabels(obj)
            table = obj.mergedTables();
            labels = table.label;
        end
    end
    
    
    methods (Access = private)
        function mergedTable = mergeTables(obj,tables)
            if isempty(tables) 
                mergedTable = [];
            else
                
                nRows = obj.countNumberOfRows(tables);
                
                firstTable = tables(1).table;
                
                mergedTableArray = zeros(nRows,width(firstTable));
                
                currentRow = 1;
                for i = 1 : length(tables)
                    currentTable = tables(i).table;
                    nRowsCurrentTable = height(currentTable);
                    mergedTableArray(currentRow : currentRow + nRowsCurrentTable - 1,:) = table2array(currentTable);
                    currentRow = currentRow + nRowsCurrentTable;
                end
                
                mergedTable = array2table(mergedTableArray);
                mergedTable.Properties.VariableNames = firstTable.Properties.VariableNames;
                mergedTable = Table(mergedTable);
            end
        end
        
        function nRows = countNumberOfRows(~,tables)
            nRows = 0;
            for i = 1 : length(tables)
                nRows = nRows + tables(i).height;
            end
        end
        
    end
end
