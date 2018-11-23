%contains a set of tales (cell array) and operations to merge them
classdef TableSet < handle
    
    properties (Access = public)
        tables;
    end
    
    methods (Access = public)
        function obj = TableSet(tables)
            obj.tables = tables;
        end
        
        function table = tableForIndices(obj,indices)
            selectedTables = obj.tables(indices);
            table = obj.mergeTables(selectedTables);
        end
        
        function table = tableAll(obj)
            table = obj.mergeTables(obj.tables);
        end
        
        function nTables = NTables(obj)
            nTables = length(obj.tables);
        end
        
        function nInstances = NInstances(obj)
            nInstances = 0;
            for i = 1 : length(obj.tables) 
                nInstances = nInstances + height(obj.tables{i});
            end
        end
        
        function labels = getAllLabels(obj)
            table = obj.tableAll();
            labels = table.label;
        end
    end
    
    
    methods (Access = private)
        function mergedTable = mergeTables(~,tables)
            nRows = 0;
            for i = 1 : length(tables)
                localTable = tables{i};
                nRows = nRows + height(localTable);
            end
            
            mergedTableArray = zeros(nRows,width(tables{1}));
            
            currentRow = 1;
            for i = 1 : length(tables)
                currentTable = tables{i};
                nRowsCurrentTable = height(currentTable);
                mergedTableArray(currentRow : currentRow + nRowsCurrentTable - 1,:) = table2array(currentTable);
                currentRow = currentRow + nRowsCurrentTable;
            end
            
            mergedTable = array2table(mergedTableArray);
            mergedTable.Properties.VariableNames = tables{1}.Properties.VariableNames;
        end
    end
end
